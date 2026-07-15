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