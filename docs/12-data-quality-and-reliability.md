# FlowOps Data Quality and Reliability

## Validation

Valid events require:

- event ID
- delivery ID
- source
- event type
- repository
- received timestamp
- schema version
- payload

## Reliability Controls

| Control | Purpose |
|---|---|
| Pub/Sub retention | Protects temporarily unprocessed messages |
| Retries | Handles transient failures |
| Dead-letter topic | Isolates repeated failures |
| Firestore idempotency | Reduces duplicate Cloud Run inserts |
| Invalid-event table | Preserves malformed messages |
| Raw payload retention | Supports audit and replay |
| Terraform | Supports repeatable recovery |

## Current Limitations

- Beam idempotency is not yet state-backed.
- Formal data contracts are not yet implemented.
- Automated replay tooling is not yet available.
- Production SLOs are not yet defined.
