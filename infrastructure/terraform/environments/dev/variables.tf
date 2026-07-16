variable "project_id" {
  description = "Google Cloud project used by FlowOps."
  type        = string
}

variable "region" {
  description = "Default Google Cloud region."
  type        = string
  default     = "us-central1"
}

variable "bigquery_location" {
  description = "Location used by FlowOps BigQuery datasets."
  type        = string
  default     = "US"
}

variable "event_processor_push_endpoint" {
  description = "Authenticated Pub/Sub push endpoint for the processor."
  type        = string
}

variable "event_processor_push_audience" {
  description = "OIDC audience used by the Pub/Sub push subscription."
  type        = string
}