# FlowOps Configuration Reference

## Main Values

| Setting | Value |
|---|---|
| Project ID | `flowops-dev` |
| Region | `us-central1` |
| Event topic | `flowops-github-events` |
| Beam subscription | `flowops-beam-stream-sub` |
| Raw dataset | `flowops_raw` |
| Standardized dataset | `flowops_standardized` |
| Analytics dataset | `flowops_analytics` |

## Cloud Run Environment Variables

Typical variables include:

```text
GCP_PROJECT_ID
PUBSUB_TOPIC_ID
BIGQUERY_DATASET
BIGQUERY_TABLE
FIRESTORE_COLLECTION
```

The GitHub webhook secret must come from Secret Manager.

## Beam Runtime Options

```text
--runner
--project
--region
--subscription
--valid-table
--invalid-table
--staging_location
--temp_location
--service_account_email
--setup_file
--streaming
```

## Secret Handling

Never store secret values in:

- source code
- README files
- screenshots
- Terraform variables committed to Git
- command history shared publicly
