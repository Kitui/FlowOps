-- ============================================================
-- FLOWOPS STANDARDIZED EVENT PIPELINE
-- ============================================================

-- 1. Standardize GitHub push events
MERGE `flowops-dev.flowops_standardized.push_events` AS target
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

        SPLIT(repository, '/')[SAFE_OFFSET(0)]
            AS repository_owner,

        JSON_VALUE(
            payload,
            '$.ref'
        ) AS branch_ref,

        REGEXP_EXTRACT(
            JSON_VALUE(payload, '$.ref'),
            r'^refs/heads/(.+)$'
        ) AS branch_name,

        JSON_VALUE(
            payload,
            '$.before'
        ) AS before_commit_sha,

        JSON_VALUE(
            payload,
            '$.after'
        ) AS after_commit_sha,

        JSON_VALUE(
            payload,
            '$.head_commit.id'
        ) AS head_commit_sha,

        JSON_VALUE(
            payload,
            '$.head_commit.message'
        ) AS head_commit_message,

        JSON_VALUE(
            payload,
            '$.pusher.name'
        ) AS pusher_name,

        JSON_VALUE(
            payload,
            '$.pusher.email'
        ) AS pusher_email,

        JSON_VALUE(
            payload,
            '$.sender.login'
        ) AS sender_login,

        COALESCE(
            ARRAY_LENGTH(
                JSON_QUERY_ARRAY(payload, '$.commits')
            ),
            0
        ) AS commit_count,

        COALESCE(
            SAFE_CAST(
                JSON_VALUE(payload, '$.created')
                AS BOOL
            ),
            FALSE
        ) AS created,

        COALESCE(
            SAFE_CAST(
                JSON_VALUE(payload, '$.deleted')
                AS BOOL
            ),
            FALSE
        ) AS deleted,

        COALESCE(
            SAFE_CAST(
                JSON_VALUE(payload, '$.forced')
                AS BOOL
            ),
            FALSE
        ) AS forced,

        received_at AS event_received_at,
        pubsub_publish_time,
        CURRENT_TIMESTAMP() AS standardized_at,
        schema_version,
        source

    FROM `flowops-dev.flowops_raw.github_events`

    WHERE event_type = 'push'
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
        branch_ref,
        branch_name,
        before_commit_sha,
        after_commit_sha,
        head_commit_sha,
        head_commit_message,
        pusher_name,
        pusher_email,
        sender_login,
        commit_count,
        created,
        deleted,
        forced,
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
        source.branch_ref,
        source.branch_name,
        source.before_commit_sha,
        source.after_commit_sha,
        source.head_commit_sha,
        source.head_commit_message,
        source.pusher_name,
        source.pusher_email,
        source.sender_login,
        source.commit_count,
        source.created,
        source.deleted,
        source.forced,
        source.event_received_at,
        source.pubsub_publish_time,
        source.standardized_at,
        source.schema_version,
        source.source
    );

-- 2. Standardize GitHub pull request events
MERGE `flowops-dev.flowops_standardized.pull_request_events` AS target
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
            JSON_VALUE(payload, '$.pull_request.id')
            AS INT64
        ) AS pull_request_id,

        SAFE_CAST(
            JSON_VALUE(payload, '$.number')
            AS INT64
        ) AS pull_request_number,

        JSON_VALUE(
            payload,
            '$.pull_request.title'
        ) AS pull_request_title,

        JSON_VALUE(
            payload,
            '$.pull_request.state'
        ) AS pull_request_state,

        JSON_VALUE(
            payload,
            '$.pull_request.html_url'
        ) AS pull_request_url,

        JSON_VALUE(
            payload,
            '$.pull_request.user.login'
        ) AS author_login,

        JSON_VALUE(
            payload,
            '$.sender.login'
        ) AS sender_login,

        JSON_VALUE(
            payload,
            '$.pull_request.base.ref'
        ) AS base_branch,

        JSON_VALUE(
            payload,
            '$.pull_request.head.ref'
        ) AS head_branch,

        JSON_VALUE(
            payload,
            '$.pull_request.head.repo.full_name'
        ) AS head_repository,

        COALESCE(
            SAFE_CAST(
                JSON_VALUE(payload, '$.pull_request.draft')
                AS BOOL
            ),
            FALSE
        ) AS draft,

        COALESCE(
            SAFE_CAST(
                JSON_VALUE(payload, '$.pull_request.merged')
                AS BOOL
            ),
            FALSE
        ) AS merged,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.mergeable')
            AS BOOL
        ) AS mergeable,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.additions')
            AS INT64
        ) AS additions,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.deletions')
            AS INT64
        ) AS deletions,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.changed_files')
            AS INT64
        ) AS changed_files,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.commits')
            AS INT64
        ) AS commit_count,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.comments')
            AS INT64
        ) AS comment_count,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.review_comments')
            AS INT64
        ) AS review_comment_count,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.created_at')
            AS TIMESTAMP
        ) AS created_at,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.updated_at')
            AS TIMESTAMP
        ) AS updated_at,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.closed_at')
            AS TIMESTAMP
        ) AS closed_at,

        SAFE_CAST(
            JSON_VALUE(payload, '$.pull_request.merged_at')
            AS TIMESTAMP
        ) AS merged_at,

        CASE
            WHEN JSON_VALUE(
                payload,
                '$.pull_request.created_at'
            ) IS NOT NULL
            AND JSON_VALUE(
                payload,
                '$.pull_request.merged_at'
            ) IS NOT NULL
            THEN TIMESTAMP_DIFF(
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.pull_request.merged_at'
                    ) AS TIMESTAMP
                ),
                SAFE_CAST(
                    JSON_VALUE(
                        payload,
                        '$.pull_request.created_at'
                    ) AS TIMESTAMP
                ),
                MINUTE
            )
        END AS merge_duration_minutes,

        received_at AS event_received_at,
        pubsub_publish_time,
        CURRENT_TIMESTAMP() AS standardized_at,
        schema_version,
        source

    FROM `flowops-dev.flowops_raw.github_events`

    WHERE event_type = 'pull_request'
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
        pull_request_id,
        pull_request_number,
        pull_request_title,
        pull_request_state,
        pull_request_url,
        author_login,
        sender_login,
        base_branch,
        head_branch,
        head_repository,
        draft,
        merged,
        mergeable,
        additions,
        deletions,
        changed_files,
        commit_count,
        comment_count,
        review_comment_count,
        created_at,
        updated_at,
        closed_at,
        merged_at,
        merge_duration_minutes,
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
        source.pull_request_id,
        source.pull_request_number,
        source.pull_request_title,
        source.pull_request_state,
        source.pull_request_url,
        source.author_login,
        source.sender_login,
        source.base_branch,
        source.head_branch,
        source.head_repository,
        source.draft,
        source.merged,
        source.mergeable,
        source.additions,
        source.deletions,
        source.changed_files,
        source.commit_count,
        source.comment_count,
        source.review_comment_count,
        source.created_at,
        source.updated_at,
        source.closed_at,
        source.merged_at,
        source.merge_duration_minutes,
        source.event_received_at,
        source.pubsub_publish_time,
        source.standardized_at,
        source.schema_version,
        source.source
    );

-- 3. Standardize GitHub workflow run events
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