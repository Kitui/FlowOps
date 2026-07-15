from datetime import datetime, timezone
from typing import Any
from uuid import uuid4

from services.webhook_receiver.app.models import FlowOpsEvent


def build_flowops_event(
    *,
    event_type: str,
    delivery_id: str,
    repository: str,
    payload: dict[str, Any],
) -> FlowOpsEvent:
    """Build a validated canonical FlowOps event envelope."""

    return FlowOpsEvent(
        event_id=str(uuid4()),
        source="github",
        event_type=event_type,
        delivery_id=delivery_id,
        repository=repository,
        received_at=datetime.now(timezone.utc),
        schema_version="1.0",
        payload=payload,
    )