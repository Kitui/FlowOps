# FlowOps Repository Onboarding

## Purpose

Connect an additional GitHub repository to FlowOps.

## Required Values

- FlowOps webhook receiver URL
- GitHub webhook secret

## GitHub Steps

1. Open the repository.
2. Go to **Settings → Webhooks**.
3. Select **Add webhook**.
4. Enter the FlowOps URL.
5. Select `application/json`.
6. Enter the webhook secret.
7. Select:
   - Pushes
   - Pull requests
   - Workflow runs
8. Save the webhook.

## Validation

Create:

- one push
- one pull request
- one workflow run

Confirm that the repository appears in:

```text
flowops_raw.github_events
flowops_raw.github_events_beam
```

## Repository Separation

FlowOps identifies each source using the `repository` field.

A future GitHub App will simplify organization-wide onboarding.
