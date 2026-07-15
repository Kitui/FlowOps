CREATE OR REPLACE VIEW
`flowops-dev.flowops_analytics.workflow_failure_details`
AS

SELECT
    event_received_at,
    repository,

    workflow_name,
    workflow_run_id,
    run_number,
    run_attempt,

    event_name,
    status,
    conclusion,

    head_branch,
    head_sha,

    actor_login,
    triggering_actor_login,

    duration_seconds,
    queue_duration_seconds,

    created_at,
    run_started_at,
    updated_at,

    workflow_run_url

FROM
    `flowops-dev.flowops_standardized.workflow_run_events`

WHERE action = 'completed'
  AND conclusion IN
  (
      'failure',
      'cancelled',
      'timed_out',
      'startup_failure'
  );