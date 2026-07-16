from __future__ import annotations

import base64
import json
from datetime import datetime, timezone
from typing import Any, Iterable

import apache_beam as beam


class ParsePubSubEvent(beam.DoFn):
    """Parse and validate a canonical FlowOps Pub/Sub event."""

    INVALID_TAG = "invalid"

    def process(self, element: bytes) -> Iterable[dict[str, Any]]:
        try:
            decoded = element.decode("utf-8")
            event = json.loads(decoded)

            if not isinstance(event, dict):
                raise ValueError("Event must be a JSON object.")

            required_fields = {
                "event_id",
                "delivery_id",
                "source",
                "event_type",
                "repository",
                "received_at",
                "schema_version",
                "payload",
            }

            missing_fields = sorted(required_fields.difference(event))

            if missing_fields:
                raise ValueError(
                    "Missing required fields: " + ", ".join(missing_fields)
                )

            event["beam_processed_at"] = datetime.now(
                timezone.utc
            ).isoformat()

            yield event

        except (
            UnicodeDecodeError,
            json.JSONDecodeError,
            TypeError,
            ValueError,
        ) as error:
            yield beam.pvalue.TaggedOutput(
                self.INVALID_TAG,
                {
                    "error": str(error),
                    "error_type": type(error).__name__,
                    "raw_payload_base64": base64.b64encode(element).decode(
                        "ascii"
                        ),
                        "failed_at": datetime.now(timezone.utc).isoformat(),
                },
            )


def to_raw_bigquery_row(event: dict[str, Any]) -> dict[str, Any]:
    """Convert a canonical FlowOps event to a BigQuery row."""

    return {
        "event_id": event["event_id"],
        "delivery_id": event["delivery_id"],
        "source": event["source"],
        "event_type": event["event_type"],
        "repository": event["repository"],
        "received_at": event["received_at"],
        "schema_version": event["schema_version"],
        "payload": json.dumps(event["payload"]),
        "beam_processed_at": event["beam_processed_at"],
        "processing_status": "processed",
    }