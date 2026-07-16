resource "google_cloud_run_v2_service_iam_member" "receiver_public_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.webhook_receiver.name

  role   = "roles/run.invoker"
  member = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "processor_pubsub_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.event_processor.name

  role = "roles/run.invoker"

  member = "serviceAccount:${google_service_account.pubsub_push.email}"
}

locals {
  runtime_project_roles = {

    processor_bigquery_editor = {
      role   = "roles/bigquery.dataEditor"
      member = "serviceAccount:${google_service_account.event_processor.email}"
    }

    processor_bigquery_job_user = {
      role   = "roles/bigquery.jobUser"
      member = "serviceAccount:${google_service_account.event_processor.email}"
    }

    processor_firestore_user = {
      role   = "roles/datastore.user"
      member = "serviceAccount:${google_service_account.event_processor.email}"
    }

    transformer_bigquery_editor = {
      role   = "roles/bigquery.dataEditor"
      member = "serviceAccount:${google_service_account.bigquery_transformer.email}"
    }

    transformer_bigquery_job_user = {
      role   = "roles/bigquery.jobUser"
      member = "serviceAccount:${google_service_account.bigquery_transformer.email}"
    }
  }
}

resource "google_project_iam_member" "runtime" {
  for_each = local.runtime_project_roles

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_secret_manager_secret_iam_member" "receiver_secret_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.github_webhook_secret.secret_id

  role   = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.webhook_receiver.email}"
}

resource "google_pubsub_topic_iam_member" "receiver_publisher" {
  project = var.project_id
  topic   = google_pubsub_topic.github_events.name

  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.webhook_receiver.email}"
}