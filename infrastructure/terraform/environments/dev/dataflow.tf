resource "google_storage_bucket" "dataflow" {
  project  = var.project_id
  name     = var.dataflow_bucket_name
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = false

  soft_delete_policy {
    retention_duration_seconds = 0
  }

  lifecycle {
    prevent_destroy = true
  }
}