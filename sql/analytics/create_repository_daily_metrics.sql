CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.repository_daily_metrics`
AS

WITH push_metrics AS
(
    SELECT
        DATE(event_received_at) AS metric_date,
        repository,

        COUNT(*) AS push_events,
        SUM(commit_count) AS commits_pushed,
        COUNT(DISTINCT pusher_name) AS active_pushers

    FROM `flowops-dev.flowops_standardized.push_events`

    GROUP BY
        metric_date,
        repository
),

pull_request_metrics AS
(
    SELECT
        DATE(event_received_at) AS metric_date,
        repository,

        COUNTIF(action = 'opened') AS pull_requests_opened,

        COUNTIF(
            action = 'closed'
            AND merged = TRUE
        ) AS pull_requests_merged,

        COUNTIF(
            action = 'closed'
            AND merged = FALSE
        ) AS pull_requests_closed_without_merge,

        AVG(
            CASE
                WHEN action = 'closed'
                 AND merged = TRUE
                THEN merge_duration_minutes
            END
        ) AS average_merge_duration_minutes

    FROM
        `flowops-dev.flowops_standardized.pull_request_events`

    GROUP BY
        metric_date,
        repository
),

workflow_metrics AS
(
    SELECT
        DATE(event_received_at) AS metric_date,
        repository,

        COUNTIF(
            action = 'completed'
        ) AS completed_workflow_runs,

        COUNTIF(
            action = 'completed'
            AND conclusion = 'success'
        ) AS successful_workflow_runs,

        COUNTIF(
            action = 'completed'
            AND conclusion = 'failure'
        ) AS failed_workflow_runs,

        AVG(
            CASE
                WHEN action = 'completed'
                THEN duration_seconds
            END
        ) AS average_workflow_duration_seconds

    FROM
        `flowops-dev.flowops_standardized.workflow_run_events`

    GROUP BY
        metric_date,
        repository
),

metric_keys AS
(
    SELECT metric_date, repository FROM push_metrics

    UNION DISTINCT

    SELECT metric_date, repository FROM pull_request_metrics

    UNION DISTINCT

    SELECT metric_date, repository FROM workflow_metrics
)

SELECT
    keys.metric_date,
    keys.repository,

    COALESCE(push.push_events, 0) AS push_events,
    COALESCE(push.commits_pushed, 0) AS commits_pushed,
    COALESCE(push.active_pushers, 0) AS active_pushers,

    COALESCE(
        pull_request.pull_requests_opened,
        0
    ) AS pull_requests_opened,

    COALESCE(
        pull_request.pull_requests_merged,
        0
    ) AS pull_requests_merged,

    COALESCE(
        pull_request.pull_requests_closed_without_merge,
        0
    ) AS pull_requests_closed_without_merge,

    ROUND(
        pull_request.average_merge_duration_minutes,
        2
    ) AS average_merge_duration_minutes,

    COALESCE(
        workflow.completed_workflow_runs,
        0
    ) AS completed_workflow_runs,

    COALESCE(
        workflow.successful_workflow_runs,
        0
    ) AS successful_workflow_runs,

    COALESCE(
        workflow.failed_workflow_runs,
        0
    ) AS failed_workflow_runs,

    ROUND(
        workflow.average_workflow_duration_seconds,
        2
    ) AS average_workflow_duration_seconds,

    ROUND(
        SAFE_DIVIDE(
            workflow.successful_workflow_runs,
            workflow.completed_workflow_runs
        ) * 100,
        2
    ) AS workflow_success_rate_percentage

FROM metric_keys AS keys

LEFT JOIN push_metrics AS push
    USING (metric_date, repository)

LEFT JOIN pull_request_metrics AS pull_request
    USING (metric_date, repository)

LEFT JOIN workflow_metrics AS workflow
    USING (metric_date, repository);