# FlowOps Troubleshooting

## Terraform Not Found

Confirm the installation path is in `PATH`:

```powershell
terraform version
```

## Terraform Drift

```powershell
terraform plan
```

Review unexpected changes before applying.

## Webhook Returns an Error

Check:

- webhook URL
- webhook secret
- `X-Hub-Signature-256`
- Cloud Run logs
- Secret Manager access

## No Pub/Sub Message

Check:

- receiver publish permissions
- topic name
- receiver logs
- GitHub delivery status

## No BigQuery Record

Check:

- subscription backlog
- processor or Dataflow logs
- table name
- service-account permissions
- invalid-event table

## Dataflow Job Fails

Check:

- worker service account
- Pub/Sub roles
- BigQuery roles
- staging bucket access
- setup file path
- worker zone capacity

## PowerShell Quoting Errors

Quote values containing spaces and prefer variables for long commands.

## Accidental `.venv` Tracking

```powershell
git rm -r --cached .venv
```

Ensure `.venv/` is listed in `.gitignore`.
