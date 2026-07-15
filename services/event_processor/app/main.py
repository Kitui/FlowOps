import base64
import binascii
import json
import logging
from typing import Any

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import ValidationError

from services.event_processor.app.models import (
    FlowOpsEvent,
    PubSubPushEnvelope,
)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)

logger = logging.getLogger(__name__)

app = FastAPI(
    title="FlowOps Event Processor",
    description=(
        "Receives, decodes, and validates FlowOps events "
        "delivered through Google Cloud Pub/Sub."
    ),
    version="0.2.0",
)


def format_validation_errors(
    validation_error: ValidationError,
) -> list[dict[str, Any]]:
    """
    Convert Pydantic validation errors into JSON-safe dictionaries.

    Pydantic validation contexts may contain Python exception objects,
    which cannot be returned directly in a JSON HTTP response.
    """
    return json.loads(validation_error.json())


@app.get("/")
async def root() -> dict[str, str]:
    """Return basic service information."""

    return {
        "service": "flowops-event-processor",
        "status": "healthy",
        "version": "0.2.0",
    }


@app.get("/health")
async def health_check() -> dict[str, str]:
    """Return processor readiness information."""

    return {
        "status": "ready",
        "schema_version": "1.0",
    }


@app.post("/pubsub/push")
async def receive_pubsub_message(
    request: Request,
) -> JSONResponse:
    """
    Receive, decode, and validate a Pub/Sub push message.

    Processing stages:
    1. Parse the HTTP request body.
    2. Validate the Pub/Sub push envelope.
    3. Decode the Base64 message data.
    4. Validate the canonical FlowOps event.
    5. Return a successful response.
    """

    # ---------------------------------------------------------
    # 1. Parse the incoming HTTP JSON body
    # ---------------------------------------------------------
    try:
        request_body: dict[str, Any] = await request.json()

    except Exception as error:
        logger.warning(
            "Request body could not be parsed as JSON | error=%s",
            str(error),
        )

        raise HTTPException(
            status_code=400,
            detail="Request body must contain valid JSON.",
        ) from error

    # ---------------------------------------------------------
    # 2. Validate the Pub/Sub push envelope
    # ---------------------------------------------------------
    try:
        pubsub_envelope = PubSubPushEnvelope.model_validate(
            request_body
        )

    except ValidationError as validation_error:
        validation_errors = format_validation_errors(
            validation_error
        )

        logger.warning(
            "Pub/Sub envelope validation failed | errors=%s",
            validation_errors,
        )

        raise HTTPException(
            status_code=400,
            detail={
                "message": "Invalid Pub/Sub push envelope.",
                "validation_errors": validation_errors,
            },
        ) from validation_error

    # ---------------------------------------------------------
    # 3. Decode the Base64 Pub/Sub message data
    # ---------------------------------------------------------
    try:
        decoded_event_bytes = base64.b64decode(
            pubsub_envelope.message.data,
            validate=True,
        )

    except (binascii.Error, ValueError) as error:
        logger.warning(
            "Pub/Sub message contains invalid Base64 | message_id=%s",
            pubsub_envelope.message.message_id,
        )

        raise HTTPException(
            status_code=400,
            detail="Pub/Sub message data is not valid Base64.",
        ) from error

    # ---------------------------------------------------------
    # 4. Validate the decoded FlowOps event
    # ---------------------------------------------------------
    try:
        flowops_event = FlowOpsEvent.model_validate_json(
            decoded_event_bytes
        )

    except ValidationError as validation_error:
        validation_errors = format_validation_errors(
            validation_error
        )

        logger.warning(
            (
                "FlowOps event validation failed | "
                "message_id=%s | errors=%s"
            ),
            pubsub_envelope.message.message_id,
            validation_errors,
        )

        raise HTTPException(
            status_code=400,
            detail={
                "message": "Invalid FlowOps event.",
                "validation_errors": validation_errors,
            },
        ) from validation_error

    # ---------------------------------------------------------
    # 5. Log successful validation
    # ---------------------------------------------------------
    logger.info(
        (
            "FlowOps event validated | "
            "message_id=%s | "
            "event_id=%s | "
            "delivery_id=%s | "
            "event_type=%s | "
            "repository=%s"
        ),
        pubsub_envelope.message.message_id,
        flowops_event.event_id,
        flowops_event.delivery_id,
        flowops_event.event_type,
        flowops_event.repository,
    )

    publish_time = pubsub_envelope.message.publish_time

    # ---------------------------------------------------------
    # 6. Return HTTP success
    # ---------------------------------------------------------
    return JSONResponse(
        status_code=200,
        content={
            "status": "validated",
            "message_id": pubsub_envelope.message.message_id,
            "publish_time": (
                publish_time.isoformat()
                if publish_time is not None
                else None
            ),
            "subscription": pubsub_envelope.subscription,
            "delivery_attempt": pubsub_envelope.delivery_attempt,
            "event_id": str(flowops_event.event_id),
            "delivery_id": flowops_event.delivery_id,
            "event_type": flowops_event.event_type,
            "repository": flowops_event.repository,
            "schema_version": flowops_event.schema_version,
        },
    )