import json
import logging
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.responses import JSONResponse

from app.config import settings
from app.publisher import publisher
from app.security import verify_github_signature
from app.utils import build_flowops_event

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)

logger = logging.getLogger(__name__)

app = FastAPI(
    title="FlowOps Webhook Receiver",
    description="Receives GitHub webhook events for the FlowOps platform.",
    version="0.5.0",
)


@app.get("/")
async def root() -> dict[str, str]:
    """Return the basic service health status."""
    return {
        "service": "flowops-webhook-receiver",
        "status": "healthy",
        "version": "0.5.0",
    }


@app.get("/health")
async def health_check() -> dict[str, str]:
    """Return the application readiness status."""
    return {
        "status": "ready",
        "project_id": settings.gcp_project_id,
        "pubsub_topic": settings.pubsub_topic_id,
    }


@app.post("/webhook/github")
async def receive_github_webhook(
    request: Request,
    x_github_event: str | None = Header(default=None),
    x_github_delivery: str | None = Header(default=None),
    x_hub_signature_256: str | None = Header(default=None),
) -> JSONResponse:
    """Verify, standardize and publish a GitHub webhook event."""

    if not x_github_event:
        raise HTTPException(
            status_code=400,
            detail="Missing X-GitHub-Event header.",
        )

    if not x_github_delivery:
        raise HTTPException(
            status_code=400,
            detail="Missing X-GitHub-Delivery header.",
        )

    if not x_hub_signature_256:
        raise HTTPException(
            status_code=401,
            detail="Missing X-Hub-Signature-256 header.",
        )

    raw_body = await request.body()

    signature_is_valid = verify_github_signature(
        payload_body=raw_body,
        signature_header=x_hub_signature_256,
        webhook_secret=settings.github_webhook_secret,
    )

    if not signature_is_valid:
        raise HTTPException(
            status_code=401,
            detail="Invalid webhook signature.",
        )

    try:
        payload: dict[str, Any] = json.loads(raw_body)
    except json.JSONDecodeError as exc:
        raise HTTPException(
            status_code=400,
            detail="Request body must contain valid JSON.",
        ) from exc

    repository_data = payload.get("repository", {})
    repository_name = repository_data.get("full_name")

    if not repository_name:
        raise HTTPException(
            status_code=400,
            detail="Webhook payload does not contain repository.full_name.",
        )

    flowops_event = build_flowops_event(
        event_type=x_github_event,
        delivery_id=x_github_delivery,
        repository=repository_name,
        payload=payload,
    )

    try:
        message_id = publisher.publish_event(flowops_event)
    except RuntimeError as exc:
        logger.exception(
            "Webhook accepted but Pub/Sub publication failed.",
            extra={
                "event_id": flowops_event.event_id,
                "delivery_id": flowops_event.delivery_id,
            },
        )

        raise HTTPException(
            status_code=503,
            detail="Pub/Sub is temporarily unavailable.",
        ) from exc

    logger.info(
        "GitHub webhook accepted and published.",
        extra={
            "event_id": flowops_event.event_id,
            "delivery_id": flowops_event.delivery_id,
            "message_id": message_id,
            "event_type": flowops_event.event_type,
            "repository": flowops_event.repository,
        },
    )

    return JSONResponse(
        status_code=202,
        content={
            "status": "published",
            "event_id": flowops_event.event_id,
            "delivery_id": flowops_event.delivery_id,
            "message_id": message_id,
            "event_type": flowops_event.event_type,
            "repository": flowops_event.repository,
        },
    )