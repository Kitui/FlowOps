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