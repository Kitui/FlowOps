CREATE TABLE IF NOT EXISTS `flowops-dev.flowops_raw.github_events`
(
    event_id STRING NOT NULL,
    delivery_id STRING NOT NULL,
    source STRING NOT NULL,
    event_type STRING NOT NULL,
    repository STRING NOT NULL,

    received_at TIMESTAMP NOT NULL,
    schema_version STRING NOT NULL,

    payload JSON NOT NULL,

    pubsub_message_id STRING NOT NULL,
    pubsub_publish_time TIMESTAMP,
    subscription STRING,
    delivery_attempt INT64,

    processed_at TIMESTAMP NOT NULL,
    processing_status STRING NOT NULL
)
PARTITION BY DATE(received_at)
CLUSTER BY repository, event_type, source
OPTIONS (
    description = "Validated raw GitHub webhook events received through the FlowOps streaming pipeline"
);