CREATE TABLE IF NOT EXISTS
`flowops-dev.flowops_standardized.workflow_run_events`
(
    event_id STRING NOT NULL,
    delivery_id STRING NOT NULL,
    repository STRING NOT NULL,

    repository_id INT64,
    repository_name STRING,
    repository_owner STRING,

    action STRING NOT NULL,

    workflow_id INT64,
    workflow_name STRING,
    workflow_path STRING,

    workflow_run_id INT64,
    run_number INT64,
    run_attempt INT64,

    event_name STRING,
    status STRING,
    conclusion STRING,

    head_branch STRING,
    head_sha STRING,

    actor_login STRING,
    triggering_actor_login STRING,
    sender_login STRING,

    workflow_url STRING,
    workflow_run_url STRING,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    run_started_at TIMESTAMP,

    duration_seconds INT64,
    queue_duration_seconds INT64,

    event_received_at TIMESTAMP NOT NULL,
    pubsub_publish_time TIMESTAMP,
    standardized_at TIMESTAMP NOT NULL,

    schema_version STRING NOT NULL,
    source STRING NOT NULL
)
PARTITION BY DATE(event_received_at)
CLUSTER BY repository, workflow_name, conclusion, head_branch
OPTIONS (
    description = "Normalized GitHub workflow run events derived from the FlowOps raw event layer"
);