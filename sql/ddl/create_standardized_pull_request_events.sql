CREATE TABLE IF NOT EXISTS
`flowops-dev.flowops_standardized.pull_request_events`
(
    event_id STRING NOT NULL,
    delivery_id STRING NOT NULL,
    repository STRING NOT NULL,

    repository_id INT64,
    repository_name STRING,
    repository_owner STRING,

    action STRING NOT NULL,

    pull_request_id INT64,
    pull_request_number INT64,
    pull_request_title STRING,
    pull_request_state STRING,
    pull_request_url STRING,

    author_login STRING,
    sender_login STRING,

    base_branch STRING,
    head_branch STRING,
    head_repository STRING,

    draft BOOLEAN,
    merged BOOLEAN,
    mergeable BOOLEAN,

    additions INT64,
    deletions INT64,
    changed_files INT64,
    commit_count INT64,
    comment_count INT64,
    review_comment_count INT64,

    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    closed_at TIMESTAMP,
    merged_at TIMESTAMP,

    merge_duration_minutes FLOAT64,

    event_received_at TIMESTAMP NOT NULL,
    pubsub_publish_time TIMESTAMP,
    standardized_at TIMESTAMP NOT NULL,

    schema_version STRING NOT NULL,
    source STRING NOT NULL
)
PARTITION BY DATE(event_received_at)
CLUSTER BY repository, action, pull_request_state, author_login
OPTIONS (
    description = "Normalized GitHub pull request events derived from the FlowOps raw event layer"
);