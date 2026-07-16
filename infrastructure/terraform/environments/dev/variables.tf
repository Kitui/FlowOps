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

variable "webhook_receiver_image" {
  description = "Container image used by the webhook receiver."
  type        = string
}

variable "event_processor_image" {
  description = "Container image used by the event processor."
  type        = string
}

variable "webhook_receiver_min_instances" {
  description = "Minimum receiver instances."
  type        = number
  default     = 0
}

variable "webhook_receiver_max_instances" {
  description = "Maximum receiver instances."
  type        = number
  default     = 2
}

variable "event_processor_min_instances" {
  description = "Minimum processor instances."
  type        = number
  default     = 0
}

variable "event_processor_max_instances" {
  description = "Maximum processor instances."
  type        = number
  default     = 3
}

variable "dataflow_bucket_name" {
  description = "Cloud Storage bucket used for Dataflow staging and temporary files."
  type        = string
}

variable "terraform_operator_email" {
  description = "Email address of the operator permitted to submit Dataflow jobs."
  type        = string
}