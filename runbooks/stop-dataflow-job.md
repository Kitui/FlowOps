# Stop Dataflow Job

## List Active Jobs

```powershell
gcloud dataflow jobs list `
    --project=flowops-dev `
    --region=us-central1 `
    --status=active `
    --format="table(id,name,state)"
```

## Cancel a Job

```powershell
gcloud dataflow jobs cancel DATAFLOW_JOB_ID `
    --project=flowops-dev `
    --region=us-central1
```

## Verify

Run the active-job list command again. No FlowOps streaming job should remain active.
