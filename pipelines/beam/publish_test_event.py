import json
from datetime import datetime, timezone

from google.cloud import pubsub_v1


project_id = "flowops-dev"
topic_id = "flowops-github-events"

event = {
    "event_id": "dataflow-stream-test-001",
    "delivery_id": "dataflow-stream-delivery-001",
    "source": "github",
    "event_type": "push",
    "repository": "Kitui/FlowOps",
    "received_at": datetime.now(timezone.utc).isoformat(),
    "schema_version": "1.0",
    "payload": {
        "ref": "refs/heads/main",
        "commits": 1,
        "test": "dataflow-streaming",
    },
}

message = json.dumps(
    event,
    separators=(",", ":"),
).encode("utf-8")

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)

future = publisher.publish(topic_path, message)

print(f"Published message ID: {future.result()}")
print(message.decode("utf-8"))
