import json
import logging
from datetime import datetime, timezone
from typing import Any

from google.cloud import bigquery

from services.event_processor.app.config import settings
from services.event_processor.app.models import (
    FlowOpsEvent,
    PubSubPushEnvelope,
)

logger = logging.getLogger(__name__)


class BigQueryWriter:
    """Write validated FlowOps events into the BigQuery raw layer."""

    def __init__(self) -> None:
        self.client = bigquery.Client(
            project=settings.gcp_project_id
        )
        self.table_id = settings.raw_table_id

    def write_raw_event(
        self,
        *,
        event: FlowOpsEvent,
        envelope: PubSubPushEnvelope,
    ) -> None:
        """Insert one validated FlowOps event into the raw table."""

        publish_time = envelope.message.publish_time

        row: dict[str, Any] = {
            "event_id": str(event.event_id),
            "delivery_id": event.delivery_id,
            "source": event.source,
            "event_type": event.event_type,
            "repository": event.repository,
            "received_at": event.received_at.isoformat(),
            "schema_version": event.schema_version,

            # Send valid JSON text for the BigQuery JSON column.
            "payload": json.dumps(
                event.payload,
                separators=(",", ":"),
            ),

            "pubsub_message_id": envelope.message.message_id,
            "pubsub_publish_time": (
                publish_time.isoformat()
                if publish_time is not None
                else None
            ),
            "subscription": envelope.subscription,
            "delivery_attempt": envelope.delivery_attempt,
            "processed_at": datetime.now(
                timezone.utc
            ).isoformat(),
            "processing_status": "processed",
        }

        try:
            errors = self.client.insert_rows_json(
                self.table_id,
                [row],
                row_ids=[str(event.event_id)],
            )

        except Exception as error:
            logger.exception(
                (
                    "BigQuery insertion request failed | "
                    "event_id=%s | table=%s | "
                    "error_type=%s | error=%s"
                ),
                event.event_id,
                self.table_id,
                type(error).__name__,
                str(error),
            )

            raise RuntimeError(
                f"BigQuery insertion request failed: {error}"
            ) from error

        if errors:
            logger.error(
                (
                    "BigQuery rejected event | "
                    "event_id=%s | table=%s | errors=%s"
                ),
                event.event_id,
                self.table_id,
                errors,
            )

            raise RuntimeError(
                f"BigQuery rejected the event: {errors}"
            )

        logger.info(
            (
                "Raw event written to BigQuery | "
                "event_id=%s | table=%s"
            ),
            event.event_id,
            self.table_id,
        )


bigquery_writer = BigQueryWriter()