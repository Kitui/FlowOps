MERGE `flowops-dev.flowops_standardized.workflow_run_events` AS target
USING
(
    SELECT
        event_id,
        delivery_id,
        repository,

        SAFE_CAST(
            JSON_VALUE(payload, '$.repository.id')
            AS INT64
        ) AS repository_id,

        JSON_VALUE(
            payload,
            '$.repository.name'
        ) AS repository_name,

        COALESCE(
            JSON_VALUE(payload, '$.repository.owner.login'),
            SPLIT(repository, '/')[SAFE_OFFSET(0)]
        ) AS repository_owner,

        JSON_VALUE(
            payload,
            '$.action'
        ) AS action,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow.id')
            AS INT64
        ) AS workflow_id,

        JSON_VALUE(
            payload,
            '$.workflow.name'
        ) AS workflow_name,

        JSON_VALUE(
            payload,
            '$.workflow.path'
        ) AS workflow_path,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.id')
            AS INT64
        ) AS workflow_run_id,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.run_number')
            AS INT64
        ) AS run_number,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.run_attempt')
            AS INT64
        ) AS run_attempt,

        JSON_VALUE(
            payload,
            '$.workflow_run.event'
        ) AS event_name,

        JSON_VALUE(
            payload,
            '$.workflow_run.status'
        ) AS status,

        JSON_VALUE(
            payload,
            '$.workflow_run.conclusion'
        ) AS conclusion,

        JSON_VALUE(
            payload,
            '$.workflow_run.head_branch'
        ) AS head_branch,

        JSON_VALUE(
            payload,
            '$.workflow_run.head_sha'
        ) AS head_sha,

        JSON_VALUE(
            payload,
            '$.workflow_run.actor.login'
        ) AS actor_login,

        JSON_VALUE(
            payload,
            '$.workflow_run.triggering_actor.login'
        ) AS triggering_actor_login,

        JSON_VALUE(
            payload,
            '$.sender.login'
        ) AS sender_login,

        JSON_VALUE(
            payload,
            '$.workflow.html_url'
        ) AS workflow_url,

        JSON_VALUE(
            payload,
            '$.workflow_run.html_url'
        ) AS workflow_run_url,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.created_at')
            AS TIMESTAMP
        ) AS created_at,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.updated_at')
            AS TIMESTAMP
        ) AS updated_at,

        SAFE_CAST(
            JSON_VALUE(payload, '$.workflow_run.run_started_at')
            AS TIMESTAMP
        ) AS run_started_at,

        CASE
            WHEN JSON_VALUE(
                payload,
                '$.workflow_run.run_started_at'
            ) IS NOT NULL
            AND JSON_VALUE(
                payload,
                '$.workflow_run.updated_at'
            ) IS NOT NULL
            THEN TIMESTAMP_DIFF(
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.workflow_run.updated_at'
                    ) AS TIMESTAMP
                ),
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.workflow_run.run_started_at'
                    ) AS TIMESTAMP
                ),
                SECOND
            )
        END AS duration_seconds,

        CASE
            WHEN JSON_VALUE(
                payload,
                '$.workflow_run.created_at'
            ) IS NOT NULL
            AND JSON_VALUE(
                payload,
                '$.workflow_run.run_started_at'
            ) IS NOT NULL
            THEN TIMESTAMP_DIFF(
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.workflow_run.run_started_at'
                    ) AS TIMESTAMP
                ),
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.workflow_run.created_at'
                    ) AS TIMESTAMP
                ),
                SECOND
            )
        END AS queue_duration_seconds,

        received_at AS event_received_at,
        pubsub_publish_time,
        CURRENT_TIMESTAMP() AS standardized_at,
        schema_version,
        source

    FROM `flowops-dev.flowops_raw.github_events`

    WHERE event_type = 'workflow_run'
      AND processing_status = 'processed'
) AS source

ON target.delivery_id = source.delivery_id

WHEN NOT MATCHED THEN
    INSERT
    (
        event_id,
        delivery_id,
        repository,
        repository_id,
        repository_name,
        repository_owner,
        action,
        workflow_id,
        workflow_name,
        workflow_path,
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
        sender_login,
        workflow_url,
        workflow_run_url,
        created_at,
        updated_at,
        run_started_at,
        duration_seconds,
        queue_duration_seconds,
        event_received_at,
        pubsub_publish_time,
        standardized_at,
        schema_version,
        source
    )
    VALUES
    (
        source.event_id,
        source.delivery_id,
        source.repository,
        source.repository_id,
        source.repository_name,
        source.repository_owner,
        source.action,
        source.workflow_id,
        source.workflow_name,
        source.workflow_path,
        source.workflow_run_id,
        source.run_number,
        source.run_attempt,
        source.event_name,
        source.status,
        source.conclusion,
        source.head_branch,
        source.head_sha,
        source.actor_login,
        source.triggering_actor_login,
        source.sender_login,
        source.workflow_url,
        source.workflow_run_url,
        source.created_at,
        source.updated_at,
        source.run_started_at,
        source.duration_seconds,
        source.queue_duration_seconds,
        source.event_received_at,
        source.pubsub_publish_time,
        source.standardized_at,
        source.schema_version,
        source.source
    );