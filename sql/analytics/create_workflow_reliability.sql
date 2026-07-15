CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.workflow_reliability`
AS

SELECT
    DATE(event_received_at) AS metric_date,
    repository,
    workflow_name,
    head_branch,

    COUNT(*) AS completed_runs,

    COUNTIF(
        conclusion = 'success'
    ) AS successful_runs,

    COUNTIF(
        conclusion = 'failure'
    ) AS failed_runs,

    COUNTIF(
        conclusion = 'cancelled'
    ) AS cancelled_runs,

    COUNTIF(
        conclusion = 'timed_out'
    ) AS timed_out_runs,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(conclusion = 'success'),
            COUNT(*)
        ) * 100,
        2
    ) AS success_rate_percentage,

    ROUND(
        AVG(duration_seconds),
        2
    ) AS average_duration_seconds,

    ROUND(
        AVG(queue_duration_seconds),
        2
    ) AS average_queue_duration_seconds,

    MAX(duration_seconds)
        AS maximum_duration_seconds,

    MIN(duration_seconds)
        AS minimum_duration_seconds,

    MAX(event_received_at)
        AS latest_run_received_at

FROM
    `flowops-dev.flowops_standardized.workflow_run_events`

WHERE action = 'completed'

GROUP BY
    metric_date,
    repository,
    workflow_name,
    head_branch;