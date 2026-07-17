# FlowOps Cost Management

## Main Cost Risk

A running Dataflow streaming job continues to incur cost even when event volume is low.

## Current Cost Controls

- Start Dataflow only for controlled tests.
- Use one worker.
- Disable autoscaling during small tests.
- Cancel the job immediately after validation.
- Keep Cloud Run services scale-to-zero.
- Use partitioned and clustered BigQuery tables.
- Store only required development data.
- Review Cloud Billing regularly.

## Check Active Jobs

```powershell
gcloud dataflow jobs list `
    --project=flowops-dev `
    --region=us-central1 `
    --status=active
```

## Additional Controls

- create budget alerts
- add Cloud Storage lifecycle rules
- expire unnecessary Pub/Sub messages
- set BigQuery table retention where appropriate
- avoid repeated full-table queries
