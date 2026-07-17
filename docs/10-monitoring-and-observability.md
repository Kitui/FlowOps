# FlowOps Monitoring and Observability

## Monitoring Goals

FlowOps should detect:

- webhook failures
- Cloud Run errors
- Pub/Sub backlog growth
- Dataflow failures
- invalid-event spikes
- missing BigQuery writes
- unexpected running cost

## Key Metrics

| Component | Metric |
|---|---|
| Cloud Run | Request count, latency, error rate |
| Pub/Sub | Unacknowledged messages, oldest message age |
| Dataflow | Job state, throughput, system lag |
| BigQuery | Recent inserts and failed jobs |
| Invalid table | Invalid-event count |
| Dead-letter subscription | Undelivered failure count |

## Logs

Use Cloud Logging for:

- webhook receiver logs
- event processor logs
- Dataflow worker logs
- service audit logs

## Recommended Alerts

- Cloud Run 5xx errors
- Pub/Sub backlog above threshold
- Dataflow job failure
- invalid-event count increase
- dead-letter message detected
- Dataflow left running unexpectedly
