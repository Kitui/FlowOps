CREATE TABLE IF NOT EXISTS
`flowops-dev.flowops_standardized.push_events`
(
    event_id STRING NOT NULL,
    delivery_id STRING NOT NULL,
    repository STRING NOT NULL,

    repository_id INT64,
    repository_name STRING,
    repository_owner STRING,

    branch_ref STRING,
    branch_name STRING,

    before_commit_sha STRING,
    after_commit_sha STRING,
    head_commit_sha STRING,
    head_commit_message STRING,

    pusher_name STRING,
    pusher_email STRING,
    sender_login STRING,

    commit_count INT64,
    created BOOLEAN,
    deleted BOOLEAN,
    forced BOOLEAN,

    event_received_at TIMESTAMP NOT NULL,
    pubsub_publish_time TIMESTAMP,
    standardized_at TIMESTAMP NOT NULL,

    schema_version STRING NOT NULL,
    source STRING NOT NULL
)
PARTITION BY DATE(event_received_at)
CLUSTER BY repository, branch_name, pusher_name
OPTIONS (
    description = "Normalized GitHub push events derived from the FlowOps raw event layer"
);