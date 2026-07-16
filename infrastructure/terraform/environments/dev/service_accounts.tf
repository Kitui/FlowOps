resource "google_service_account" "webhook_receiver" {
  project      = var.project_id
  account_id   = "flowops-webhook-receiver"
  display_name = "FlowOps Webhook Receiver"
}

resource "google_service_account" "event_processor" {
  project      = var.project_id
  account_id   = "flowops-event-processor"
  display_name = "FlowOps Event Processor"
}

resource "google_service_account" "pubsub_push" {
  project      = var.project_id
  account_id   = "flowops-pubsub-push"
  display_name = "FlowOps Pub/Sub Push"
}

resource "google_service_account" "bigquery_transformer" {
  project      = var.project_id
  account_id   = "flowops-bigquery-transformer"
  display_name = "FlowOps BigQuery Transformer"
}