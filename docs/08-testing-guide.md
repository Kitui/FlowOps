# FlowOps Testing Guide

## Unit Tests

Run from the repository root:

```powershell
pytest
```

Expected:

```text
All tests passed
```

## Local Webhook Test

Start the receiver:

```powershell
uvicorn services.webhook_receiver.app.main:app --reload
```

Send a signed test request and confirm:

- HTTP success
- event type detected
- repository detected
- Pub/Sub message published

## Beam Tests

Run Beam tests:

```powershell
pytest pipelineseam	ests
```

Validate:

- valid event parsing
- invalid event routing
- required-field validation

## Real GitHub Tests

Create:

1. one push
2. one pull request
3. one workflow run
4. one controlled workflow failure

Confirm each event in BigQuery.

## Infrastructure Tests

```powershell
terraform fmt -check
terraform validate
terraform plan
```

Expected plan:

```text
No changes. Your infrastructure matches the configuration.
```
