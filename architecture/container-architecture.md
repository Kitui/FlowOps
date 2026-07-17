# Container Architecture

```mermaid
flowchart LR
    GH[GitHub] --> WR[Webhook Receiver]
    WR --> PS[Pub/Sub]
    PS --> EP[Event Processor]
    PS --> DF[Dataflow]
    EP --> FS[Firestore]
    EP --> BQ[BigQuery]
    DF --> BQ
    SM[Secret Manager] --> WR
```

| Container | Purpose |
|---|---|
| Webhook receiver | Secure event ingestion |
| Pub/Sub | Event transport |
| Event processor | Serverless validation and storage |
| Dataflow | Distributed stream processing |
| Firestore | Idempotency state |
| BigQuery | Analytical storage |
