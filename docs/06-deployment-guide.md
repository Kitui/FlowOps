# FlowOps Deployment Guide

## Prerequisites

- Google Cloud CLI
- Terraform
- Python 3.12
- Git
- GitHub CLI
- Docker
- A Google Cloud project

## Deployment Order

1. Authenticate with Google Cloud.
2. Configure the project and region.
3. Deploy infrastructure with Terraform.
4. Build and deploy the Cloud Run services.
5. Create a GitHub webhook using the receiver URL and secret.
6. Run local tests.
7. Start Dataflow when managed streaming is required.
8. Verify records in BigQuery.

## Terraform

```powershell
Set-Location infrastructure	erraform\environments\dev
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Verify Cloud Run

```powershell
gcloud run services list `
    --project=flowops-dev `
    --region=us-central1
```

## Verify Pub/Sub

```powershell
gcloud pubsub topics list --project=flowops-dev
gcloud pubsub subscriptions list --project=flowops-dev
```

## Verify BigQuery

```powershell
bq ls --project_id=flowops-dev
```

## Final Validation

Send one push, pull request, and workflow event, then confirm the records in BigQuery.
