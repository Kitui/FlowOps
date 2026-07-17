# FlowOps Disaster Recovery

## Recovery Objectives

The current project prioritizes infrastructure recreation and event preservation rather than cross-region failover.

## Recovery Sources

- Git repository
- Terraform configuration
- BigQuery raw data
- Pub/Sub retained messages
- Dead-letter messages
- Secret Manager versions
- Container images

## Recovery Procedure

1. Confirm the Google Cloud project is available.
2. Restore required secrets.
3. Run Terraform.
4. Redeploy Cloud Run services.
5. Verify Pub/Sub subscriptions.
6. Confirm BigQuery tables.
7. Restart Dataflow when required.
8. Send a test GitHub event.
9. Replay retained failures where appropriate.

## Current Limitations

- no secondary region
- no automated failover
- no formal RPO or RTO
- no automated event replay
