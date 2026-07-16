resource "google_bigquery_table" "beam_github_events" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "github_events_beam"

  deletion_protection = true

  time_partitioning {
    type  = "DAY"
    field = "received_at"
  }

  clustering = [
    "repository",
    "event_type",
    "source"
  ]

  schema = jsonencode([
    {
      name = "event_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "delivery_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "event_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "repository"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "received_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "schema_version"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "payload"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "beam_processed_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "processing_status"
      type = "STRING"
      mode = "REQUIRED"
    }
  ])

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigquery_table" "beam_invalid_events" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.raw.dataset_id
  table_id   = "invalid_events_beam"

  deletion_protection = true

  time_partitioning {
    type  = "DAY"
    field = "failed_at"
  }

  clustering = [
    "error_type"
  ]

  schema = jsonencode([
    {
      name = "error"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "error_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "raw_payload_base64"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "failed_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  lifecycle {
    prevent_destroy = true
  }
}