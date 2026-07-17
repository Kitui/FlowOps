# FlowOps Data Dictionary

## `flowops_raw.github_events_beam`

| Field | Type | Description |
|---|---|---|
| `event_id` | STRING | FlowOps event identifier |
| `delivery_id` | STRING | GitHub delivery identifier |
| `source` | STRING | Event source |
| `event_type` | STRING | GitHub event type |
| `repository` | STRING | Repository full name |
| `received_at` | TIMESTAMP | Ingestion time |
| `schema_version` | STRING | Envelope schema version |
| `payload` | JSON | Original GitHub event |
| `beam_processed_at` | TIMESTAMP | Beam processing time |
| `processing_status` | STRING | Processing result |

## `flowops_raw.invalid_events_beam`

| Field | Type | Description |
|---|---|---|
| `error` | STRING | Validation or parsing message |
| `error_type` | STRING | Error category |
| `raw_payload_base64` | STRING | Original encoded message |
| `failed_at` | TIMESTAMP | Failure time |

## Common Standardized Fields

| Field | Description |
|---|---|
| `repository` | Source repository |
| `event_type` | Push, pull request, or workflow run |
| `action` | GitHub event action |
| `branch` | Relevant Git branch |
| `author` | GitHub actor |
| `event_timestamp` | Source or processing time |
