from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class FlowOpsEvent(BaseModel):
    """Validated canonical event received from the webhook receiver."""

    model_config = ConfigDict(extra="forbid")

    event_id: UUID
    source: Literal["github"]

    event_type: str = Field(
        min_length=1,
        max_length=100,
        pattern=r"^[a-z0-9_]+$",
    )

    delivery_id: str = Field(
        min_length=1,
        max_length=255,
    )

    repository: str = Field(
        min_length=3,
        max_length=255,
    )

    received_at: datetime

    schema_version: Literal["1.0"]

    payload: dict[str, Any]

    @field_validator("repository")
    @classmethod
    def validate_repository_name(cls, value: str) -> str:
        """Require the GitHub owner/repository format."""

        owner, separator, repository = value.partition("/")

        if not separator or not owner.strip() or not repository.strip():
            raise ValueError(
                "Repository must use the format owner/repository."
            )

        return value

    @field_validator("received_at")
    @classmethod
    def validate_received_at_timezone(
        cls,
        value: datetime,
    ) -> datetime:
        """Require a timezone-aware event timestamp."""

        if value.tzinfo is None or value.utcoffset() is None:
            raise ValueError(
                "received_at must include timezone information."
            )

        return value

    @field_validator("payload")
    @classmethod
    def validate_payload(
        cls,
        value: dict[str, Any],
    ) -> dict[str, Any]:
        """Reject empty event payloads."""

        if not value:
            raise ValueError("payload must not be empty.")

        return value


class PubSubMessage(BaseModel):
    """Wrapped Pub/Sub message delivered to the processor."""

    model_config = ConfigDict(
        populate_by_name=True,
        extra="ignore",
    )

    data: str = Field(min_length=1)

    message_id: str = Field(
        alias="messageId",
        min_length=1,
    )

    publish_time: datetime | None = Field(
        default=None,
        alias="publishTime",
    )

    attributes: dict[str, str] = Field(
        default_factory=dict,
    )


class PubSubPushEnvelope(BaseModel):
    """HTTP envelope used by a Pub/Sub push subscription."""

    model_config = ConfigDict(
        populate_by_name=True,
        extra="ignore",
    )

    message: PubSubMessage

    subscription: str | None = None

    delivery_attempt: int | None = Field(
        default=None,
        alias="deliveryAttempt",
    )