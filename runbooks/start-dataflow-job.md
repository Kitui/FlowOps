# Start Dataflow Job

## Terminal 2

```powershell
Set-Location C:\Users\user\flowops
$SetupFile = (Resolve-Path pipelines\beam\setup.py).Path
$JobName = "flowops-stream-" + (Get-Date -Format "yyyyMMdd-HHmmss")
```

Run the Beam pipeline with:

```powershell
python -m flowops_beam.pipeline `
    --input-mode pubsub `
    --subscription "projects/flowops-dev/subscriptions/flowops-beam-stream-sub" `
    --output-mode bigquery `
    --valid-table "flowops-dev:flowops_raw.github_events_beam" `
    --invalid-table "flowops-dev:flowops_raw.invalid_events_beam" `
    --runner DataflowRunner `
    --project flowops-dev `
    --region us-central1 `
    --job_name $JobName `
    --staging_location "gs://flowops-dev-dataflow-523123766839/staging" `
    --temp_location "gs://flowops-dev-dataflow-523123766839/temp" `
    --service_account_email "flowops-dataflow-worker@flowops-dev.iam.gserviceaccount.com" `
    --setup_file $SetupFile `
    --streaming `
    --num_workers 1 `
    --autoscaling_algorithm NONE `
    --worker_machine_type "e2-standard-2" `
    --worker_zone "us-central1-b"
```

Confirm the job becomes active before sending events.
