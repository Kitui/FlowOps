CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.pull_request_performance`
AS

SELECT
    repository,
    pull_request_number,

    MAX(pull_request_title) AS pull_request_title,
    MAX(author_login) AS author_login,
    MAX(base_branch) AS base_branch,
    MAX(head_branch) AS head_branch,

    MIN(created_at) AS created_at,
    MAX(updated_at) AS last_updated_at,
    MAX(closed_at) AS closed_at,
    MAX(merged_at) AS merged_at,

    LOGICAL_OR(merged) AS merged,

    MAX(commit_count) AS commit_count,
    MAX(additions) AS additions,
    MAX(deletions) AS deletions,
    MAX(changed_files) AS changed_files,

    COUNTIF(action = 'synchronize')
        AS synchronization_count,

    COUNT(DISTINCT delivery_id)
        AS lifecycle_event_count,

    MAX(
        CASE
            WHEN action = 'closed'
             AND merged = TRUE
            THEN merge_duration_minutes
        END
    ) AS merge_duration_minutes,

    CASE
        WHEN LOGICAL_OR(merged)
        THEN 'merged'

        WHEN COUNTIF(action = 'closed') > 0
        THEN 'closed_without_merge'

        ELSE 'open'
    END AS lifecycle_status,

    MAX(event_received_at)
        AS latest_event_received_at

FROM
    `flowops-dev.flowops_standardized.pull_request_events`

GROUP BY
    repository,
    pull_request_number;