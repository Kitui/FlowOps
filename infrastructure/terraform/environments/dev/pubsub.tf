resource "google_pubsub_topic" "github_events" {
  project = var.project_id
  name    = "flowops-github-events"
}

resource "google_pubsub_topic" "alert_events" {
  project = var.project_id
  name    = "flowops-alert-events"
}

resource "google_pubsub_topic" "dead_letter_events" {
  project = var.project_id
  name    = "flowops-dead-letter-events"
}

resource "google_pubsub_subscription" "event_processor" {
  project = var.project_id
  name    = "flowops-event-processor-sub"
  topic   = google_pubsub_topic.github_events.id

  ack_deadline_seconds = 600

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "300s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter_events.id
    max_delivery_attempts = 5
  }

  push_config {
    push_endpoint = var.event_processor_push_endpoint

    oidc_token {
      service_account_email = (
        google_service_account.pubsub_push.email
      )

      audience = var.event_processor_push_audience
    }
  }
}

resource "google_pubsub_subscription" "dead_letter" {
  project = var.project_id
  name    = "flowops-dead-letter-sub"
  topic   = google_pubsub_topic.dead_letter_events.id

  ack_deadline_seconds = 60
}

resource "google_pubsub_subscription" "beam_stream" {
  project = var.project_id
  name    = "flowops-beam-stream-sub"
  topic   = google_pubsub_topic.github_events.id

  ack_deadline_seconds       = 60
  message_retention_duration = "86400s"
}