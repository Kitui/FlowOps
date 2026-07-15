import json
import logging

from google.api_core.exceptions import GoogleAPICallError, RetryError
from google.cloud import pubsub_v1

from app.config import settings
from app.models import FlowOpsEvent

logger = logging.getLogger(__name__)


class PubSubPublisher:
    """Publish canonical FlowOps events to Google Cloud Pub/Sub."""

    def __init__(self) -> None:
        self.client = pubsub_v1.PublisherClient()
        self.topic_path = self.client.topic_path(
            settings.gcp_project_id,
            settings.pubsub_topic_id,
        )

    def publish_event(self, event: FlowOpsEvent) -> str:
        """
        Publish an event and return the Pub/Sub message ID.

        Pub/Sub message data must be bytes, so the Pydantic model is
        serialized to JSON and then encoded as UTF-8.
        """

        event_json = event.model_dump_json()
        event_bytes = event_json.encode("utf-8")

        try:
            publish_future = self.client.publish(
                self.topic_path,
                event_bytes,
                event_type=event.event_type,
                source=event.source,
                repository=event.repository,
                schema_version=event.schema_version,
            )

            message_id = publish_future.result(timeout=10)

        except (GoogleAPICallError, RetryError, TimeoutError) as exc:
            logger.exception(
                "Failed to publish FlowOps event to Pub/Sub.",
                extra={
                    "event_id": event.event_id,
                    "delivery_id": event.delivery_id,
                },
            )
            raise RuntimeError(
                "The event could not be published to Pub/Sub."
            ) from exc

        logger.info(
            "FlowOps event published to Pub/Sub.",
            extra={
                "event_id": event.event_id,
                "message_id": message_id,
                "topic": self.topic_path,
            },
        )

        return message_id


publisher = PubSubPublisher()