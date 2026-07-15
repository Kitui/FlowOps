CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.engineering_activity`
AS

WITH push_activity AS
(
    SELECT
        DATE(event_received_at) AS activity_date,
        repository,
        pusher_name AS contributor,

        COUNT(*) AS push_events,
        SUM(commit_count) AS commits_pushed,

        0 AS pull_requests_opened,
        0 AS pull_requests_merged

    FROM
        `flowops-dev.flowops_standardized.push_events`

    GROUP BY
        activity_date,
        repository,
        contributor
),

pull_request_activity AS
(
    SELECT
        DATE(event_received_at) AS activity_date,
        repository,
        author_login AS contributor,

        0 AS push_events,
        0 AS commits_pushed,

        COUNTIF(
            action = 'opened'
        ) AS pull_requests_opened,

        COUNTIF(
            action = 'closed'
            AND merged = TRUE
        ) AS pull_requests_merged

    FROM
        `flowops-dev.flowops_standardized.pull_request_events`

    GROUP BY
        activity_date,
        repository,
        contributor
)

SELECT
    activity_date,
    repository,
    contributor,

    SUM(push_events)
        AS push_events,

    SUM(commits_pushed)
        AS commits_pushed,

    SUM(pull_requests_opened)
        AS pull_requests_opened,

    SUM(pull_requests_merged)
        AS pull_requests_merged,

    SUM(push_events)
    + SUM(pull_requests_opened)
    + SUM(pull_requests_merged)
        AS total_engineering_actions

FROM
(
    SELECT * FROM push_activity

    UNION ALL

    SELECT * FROM pull_request_activity
)

WHERE contributor IS NOT NULL

GROUP BY
    activity_date,
    repository,
    contributor;