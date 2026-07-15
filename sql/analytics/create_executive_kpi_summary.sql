CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.executive_kpi_summary`
AS

WITH push_summary AS
(
    SELECT
        COUNT(*) AS total_push_events,
        SUM(commit_count) AS total_commits_pushed,
        COUNT(DISTINCT repository) AS repositories_with_pushes,
        COUNT(DISTINCT pusher_name) AS active_pushers,
        MAX(event_received_at) AS latest_push_at

    FROM
        `flowops-dev.flowops_standardized.push_events`
),

pull_request_summary AS
(
    SELECT
        COUNTIF(action = 'opened')
            AS total_pull_requests_opened,

        COUNTIF(
            action = 'closed'
            AND merged = TRUE
        ) AS total_pull_requests_merged,

        COUNTIF(
            action = 'closed'
            AND merged = FALSE
        ) AS total_pull_requests_closed_without_merge,

        ROUND(
            AVG(
                CASE
                    WHEN action = 'closed'
                     AND merged = TRUE
                    THEN merge_duration_minutes
                END
            ),
            2
        ) AS average_merge_duration_minutes,

        MAX(event_received_at)
            AS latest_pull_request_event_at

    FROM
        `flowops-dev.flowops_standardized.pull_request_events`
),

workflow_summary AS
(
    SELECT
        COUNT(*) AS total_completed_workflow_runs,

        COUNTIF(conclusion = 'success')
            AS successful_workflow_runs,

        COUNTIF(conclusion = 'failure')
            AS failed_workflow_runs,

        COUNTIF(conclusion = 'cancelled')
            AS cancelled_workflow_runs,

        ROUND(
            SAFE_DIVIDE(
                COUNTIF(conclusion = 'success'),
                COUNT(*)
            ) * 100,
            2
        ) AS workflow_success_rate_percentage,

        ROUND(
            AVG(duration_seconds),
            2
        ) AS average_workflow_duration_seconds,

        MAX(event_received_at)
            AS latest_workflow_run_at

    FROM
        `flowops-dev.flowops_standardized.workflow_run_events`

    WHERE action = 'completed'
)

SELECT
    CURRENT_TIMESTAMP() AS calculated_at,

    COALESCE(
        push.total_push_events,
        0
    ) AS total_push_events,

    COALESCE(
        push.total_commits_pushed,
        0
    ) AS total_commits_pushed,

    COALESCE(
        push.repositories_with_pushes,
        0
    ) AS repositories_with_pushes,

    COALESCE(
        push.active_pushers,
        0
    ) AS active_pushers,

    COALESCE(
        pull_request.total_pull_requests_opened,
        0
    ) AS total_pull_requests_opened,

    COALESCE(
        pull_request.total_pull_requests_merged,
        0
    ) AS total_pull_requests_merged,

    COALESCE(
        pull_request.total_pull_requests_closed_without_merge,
        0
    ) AS total_pull_requests_closed_without_merge,

    pull_request.average_merge_duration_minutes,

    COALESCE(
        workflow.total_completed_workflow_runs,
        0
    ) AS total_completed_workflow_runs,

    COALESCE(
        workflow.successful_workflow_runs,
        0
    ) AS successful_workflow_runs,

    COALESCE(
        workflow.failed_workflow_runs,
        0
    ) AS failed_workflow_runs,

    COALESCE(
        workflow.cancelled_workflow_runs,
        0
    ) AS cancelled_workflow_runs,

    workflow.workflow_success_rate_percentage,
    workflow.average_workflow_duration_seconds,

    push.latest_push_at,
    pull_request.latest_pull_request_event_at,
    workflow.latest_workflow_run_at

FROM push_summary AS push

CROSS JOIN pull_request_summary AS pull_request

CROSS JOIN workflow_summary AS workflow;