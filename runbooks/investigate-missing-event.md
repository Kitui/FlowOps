# Investigate a Missing Event

1. Check the GitHub webhook delivery status.
2. Review webhook receiver logs.
3. Confirm the message was published to Pub/Sub.
4. Check subscription backlog.
5. Review Cloud Run processor or Dataflow logs.
6. Query valid and invalid BigQuery tables.
7. Check dead-letter messages.
8. Confirm IAM permissions and resource names.

Use the GitHub delivery ID to trace the event through each component.
