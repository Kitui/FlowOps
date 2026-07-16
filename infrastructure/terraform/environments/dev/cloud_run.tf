resource "google_cloud_run_v2_service" "webhook_receiver" {
  project  = var.project_id
  name     = "flowops-webhook-receiver"
  location = var.region

  deletion_protection = true

  template {
    service_account = google_service_account.webhook_receiver.email
    timeout         = "30s"

    scaling {
      min_instance_count = var.webhook_receiver_min_instances
      max_instance_count = var.webhook_receiver_max_instances
    }

    containers {
      image = var.webhook_receiver_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
        }

        cpu_idle          = true
        startup_cpu_boost = true
      }

      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "PUBSUB_TOPIC_ID"
        value = google_pubsub_topic.github_events.name
      }

      env {
        name = "GITHUB_WEBHOOK_SECRET"

        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.github_webhook_secret.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      client,
      client_version,
      build_config
    ]
  }
}

resource "google_cloud_run_v2_service" "event_processor" {
  project  = var.project_id
  name     = "flowops-event-processor"
  location = var.region

  deletion_protection = true

  template {
    service_account = google_service_account.event_processor.email
    timeout         = "60s"

    scaling {
      min_instance_count = var.event_processor_min_instances
      max_instance_count = 2
    }

    containers {
      image = var.event_processor_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }

        cpu_idle          = true
        startup_cpu_boost = true
      }

      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "BIGQUERY_RAW_DATASET"
        value = google_bigquery_dataset.raw.dataset_id
      }

      env {
        name  = "BIGQUERY_RAW_TABLE"
        value = "github_events"
      }

      env {
        name  = "IDEMPOTENCY_COLLECTION"
        value = "processed_events"
      }

      env {
        name  = "IDEMPOTENCY_LEASE_SECONDS"
        value = "300"
      }
    }
  }

  ingress = "INGRESS_TRAFFIC_ALL"

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      client,
      client_version,
      build_config
    ]
  }
}