resource "google_bigquery_dataset" "raw" {
  project    = var.project_id
  dataset_id = "flowops_raw"
  location   = var.bigquery_location

  description = "Validated raw GitHub webhook events."

  delete_contents_on_destroy = false
}

resource "google_bigquery_dataset" "standardized" {
  project    = var.project_id
  dataset_id = "flowops_standardized"
  location   = var.bigquery_location

  description = "Normalized and typed GitHub engineering events."

  delete_contents_on_destroy = false
}

resource "google_bigquery_dataset" "analytics" {
  project    = var.project_id
  dataset_id = "flowops_analytics"
  location   = var.bigquery_location

  description = "Dashboard-ready engineering and CI/CD metrics."

  delete_contents_on_destroy = false
}