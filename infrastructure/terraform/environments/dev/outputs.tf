output "bigquery_datasets" {
  description = "FlowOps BigQuery datasets."

  value = {
    raw          = google_bigquery_dataset.raw.dataset_id
    standardized = google_bigquery_dataset.standardized.dataset_id
    analytics    = google_bigquery_dataset.analytics.dataset_id
  }
}

output "pubsub_topics" {
  description = "FlowOps Pub/Sub topics."

  value = {
    github_events      = google_pubsub_topic.github_events.name
    alert_events       = google_pubsub_topic.alert_events.name
    dead_letter_events = google_pubsub_topic.dead_letter_events.name
  }
}

output "service_accounts" {
  description = "FlowOps runtime service accounts."

  value = {
    webhook_receiver     = google_service_account.webhook_receiver.email
    event_processor      = google_service_account.event_processor.email
    pubsub_push          = google_service_account.pubsub_push.email
    bigquery_transformer = google_service_account.bigquery_transformer.email
  }
}