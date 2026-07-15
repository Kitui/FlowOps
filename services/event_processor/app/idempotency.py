import logging
from datetime import datetime, timedelta, timezone
from enum import Enum
from typing import Any

from google.api_core.exceptions import GoogleAPICallError
from google.cloud import firestore

from services.event_processor.app.config import settings
from services.event_processor.app.models import FlowOpsEvent

logger = logging.getLogger(__name__)


class ClaimResult(str, Enum):
    """Possible outcomes when claiming an event for processing."""

    CLAIMED = "claimed"
    DUPLICATE_COMPLETED = "duplicate_completed"
    DUPLICATE_PROCESSING = "duplicate_processing"


@firestore.transactional
def claim_in_transaction(
    transaction: firestore.Transaction,
    document: firestore.DocumentReference,
    event: FlowOpsEvent,
    pubsub_message_id: str,
) -> ClaimResult:
    """
    Atomically claim an event for processing.

    This must be a module-level function because Firestore's transactional
    decorator expects the transaction object to be the first argument.
    """

    snapshot = document.get(transaction=transaction)

    now = datetime.now(timezone.utc)
    lease_until = now + timedelta(
        seconds=settings.idempotency_lease_seconds
    )

    if snapshot.exists:
        existing: dict[str, Any] = snapshot.to_dict() or {}

        status = existing.get("status")
        existing_lease = existing.get("lease_until")

        if status == "completed":
            return ClaimResult.DUPLICATE_COMPLETED

        if (
            status == "processing"
            and isinstance(existing_lease, datetime)
            and existing_lease > now
        ):
            return ClaimResult.DUPLICATE_PROCESSING

    transaction.set(
        document,
        {
            "delivery_id": event.delivery_id,
            "event_id": str(event.event_id),
            "event_type": event.event_type,
            "repository": event.repository,
            "pubsub_message_id": pubsub_message_id,
            "status": "processing",
            "claimed_at": now,
            "lease_until": lease_until,
            "updated_at": now,
        },
    )

    return ClaimResult.CLAIMED


class IdempotencyStore:
    """Coordinate event processing using Firestore documents."""

    def __init__(self) -> None:
        self.client = firestore.Client(
            project=settings.gcp_project_id
        )

        self.collection = self.client.collection(
            settings.idempotency_collection
        )

    def claim_event(
        self,
        *,
        event: FlowOpsEvent,
        pubsub_message_id: str,
    ) -> ClaimResult:
        """Atomically claim an event using its GitHub delivery ID."""

        document = self.collection.document(event.delivery_id)
        transaction = self.client.transaction()

        return claim_in_transaction(
            transaction,
            document,
            event,
            pubsub_message_id,
        )

    def mark_completed(
        self,
        *,
        delivery_id: str,
    ) -> None:
        """Mark an event as successfully stored."""

        now = datetime.now(timezone.utc)

        self.collection.document(delivery_id).update(
            {
                "status": "completed",
                "completed_at": now,
                "updated_at": now,
                "lease_until": None,
            }
        )

    def mark_failed(
        self,
        *,
        delivery_id: str,
        error_message: str,
    ) -> None:
        """Release the processing lease so Pub/Sub can retry."""

        now = datetime.now(timezone.utc)

        try:
            self.collection.document(delivery_id).update(
                {
                    "status": "failed",
                    "error_message": error_message[:1000],
                    "updated_at": now,
                    "lease_until": now,
                }
            )

        except GoogleAPICallError:
            logger.exception(
                "Failed to update idempotency record | delivery_id=%s",
                delivery_id,
            )


idempotency_store = IdempotencyStore()