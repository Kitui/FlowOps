# FlowOps Security

## Security Controls

- GitHub webhooks use HMAC SHA-256 verification.
- Only the webhook receiver is public.
- The event processor requires authenticated invocation.
- Secrets are stored in Secret Manager.
- Services use separate service accounts.
- IAM roles follow least privilege.
- Terraform manages access policies.
- Secret values are excluded from Git.

## Trust Boundaries

```text
GitHub
→ Public signed webhook endpoint
→ Private Pub/Sub processing
→ Private storage and analytics services
```

## Secret Rotation

1. Create a new Secret Manager version.
2. Update the GitHub webhook secret.
3. Confirm Cloud Run uses the latest version.
4. Send a test event.
5. Disable obsolete secret versions.

## Production Improvements

- private Dataflow workers
- restricted egress
- organization policies
- VPC Service Controls
- formal access reviews
- automated security alerts
