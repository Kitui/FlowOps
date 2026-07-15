from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class FlowOpsEvent(BaseModel):
    """Canonical event envelope used across the FlowOps platform."""

    event_id: str = Field(
        ...,
        description="Unique FlowOps event identifier.",
    )
    source: str = Field(
        default="github",
        description="System that produced the event.",
    )
    event_type: str = Field(
        ...,
        description="GitHub event type, such as push or pull_request.",
    )
    delivery_id: str = Field(
        ...,
        description="Unique GitHub webhook delivery identifier.",
    )
    repository: str = Field(
        ...,
        description="Full repository name.",
    )
    received_at: datetime = Field(
        ...,
        description="UTC time when FlowOps received the event.",
    )
    schema_version: str = Field(
        default="1.0",
        description="Version of the canonical event schema.",
    )
    payload: dict[str, Any] = Field(
        ...,
        description="Original GitHub webhook payload.",
    )