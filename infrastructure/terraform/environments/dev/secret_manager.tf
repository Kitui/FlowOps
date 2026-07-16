resource "google_secret_manager_secret" "github_webhook_secret" {
  project   = var.project_id
  secret_id = "flowops-github-webhook-secret"

  replication {
    auto {}
  }
}