# FlowOps Data Architecture

## Data Layers

| Dataset | Purpose |
|---|---|
| `flowops_raw` | Original, Beam-processed, and invalid events |
| `flowops_standardized` | Clean event-specific tables |
| `flowops_analytics` | Reporting views and engineering metrics |

```text
GitHub → Raw → Standardized → Analytics
```

## Raw Tables

```text
flowops_raw.github_events
flowops_raw.github_events_beam
flowops_raw.invalid_events_beam
```

## Canonical Event Fields

| Field | Meaning |
|---|---|
| `event_id` | FlowOps event identifier |
| `delivery_id` | GitHub delivery identifier |
| `source` | Source platform |
| `event_type` | Push, pull request, or workflow run |
| `repository` | Repository full name |
| `received_at` | Ingestion timestamp |
| `schema_version` | Event schema version |
| `payload` | Original GitHub payload |

## Standardized Layer

Extracts useful fields such as:

- branch and commit count
- PR number, title, action, and merge state
- workflow name, status, and conclusion

## Data Quality

- Required fields are validated.
- Invalid Beam events are isolated.
- Firestore reduces duplicate Cloud Run inserts.
- Raw payloads are retained for audit and reprocessing.
