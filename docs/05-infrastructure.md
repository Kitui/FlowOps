# FlowOps Infrastructure

## Environment

```text
Project: flowops-dev
Region: us-central1
```

## Core Resources

| Service | Resource |
|---|---|
| Cloud Run | `flowops-webhook-receiver` |
| Cloud Run | `flowops-event-processor` |
| Pub/Sub | `flowops-github-events` |
| Pub/Sub | `flowops-dead-letter-events` |
| Dataflow | Beam streaming job |
| BigQuery | Raw, standardized, and analytics datasets |
| Firestore | `processed_events` |
| Secret Manager | `flowops-github-webhook-secret` |
| Cloud Storage | Dataflow staging bucket |

## Service Accounts

- Webhook receiver
- Event processor
- Pub/Sub push identity
- BigQuery transformer
- Dataflow worker

## Terraform

Environment path:

```text
infrastructure/terraform/environments/dev
```

Standard workflow:

```powershell
terraform fmt
terraform validate
terraform plan
terraform apply
```

Infrastructure principles:

- least privilege
- separate service identities
- no secrets in source control
- repeatable deployment
- cost-controlled development
