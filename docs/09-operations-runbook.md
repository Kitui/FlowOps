# FlowOps Operations Runbook

## Daily Checks

- Confirm Cloud Run services are healthy.
- Check Pub/Sub backlog.
- Review recent BigQuery events.
- Inspect failed or invalid events.
- Confirm no unnecessary Dataflow job is running.

## Check Active Dataflow Jobs

```powershell
gcloud dataflow jobs list `
    --project=flowops-dev `
    --region=us-central1 `
    --status=active
```

## Check Cloud Run

```powershell
gcloud run services list `
    --project=flowops-dev `
    --region=us-central1
```

## Check Pub/Sub Backlog

Use Cloud Monitoring or inspect subscription metrics in the Google Cloud Console.

## Check Recent Events

```powershell
bq query `
    --project_id=flowops-dev `
    --use_legacy_sql=false `
    "SELECT event_type, repository, received_at FROM ``flowops-dev.flowops_raw.github_events_beam`` ORDER BY received_at DESC LIMIT 20"
```

## Incident Priorities

1. Stop unexpected cost.
2. Confirm event ingestion.
3. Check retries and backlog.
4. Inspect logs.
5. Review invalid or dead-letter messages.
6. Restore processing and document the cause.
