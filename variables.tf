variable "project_id" {
  description = "The GCP project ID where WIF resources will be provisioned."
  type        = string
}

variable "region" {
  description = "The default GCP region."
  type        = string
  default     = "us-central1"
}

variable "workload_identity_pool_id" {
  description = "The ID of the Workload Identity Pool."
  type        = string
  default     = "github-actions-pool"
}

variable "workload_identity_provider_id" {
  description = "The ID of the Workload Identity Pool Provider."
  type        = string
  default     = "github-actions-provider"
}

variable "service_account_id" {
  description = "The account ID for the Google Cloud Service Account."
  type        = string
  default     = "codemender-github-sa"
}

variable "github_repository" {
  description = "The GitHub repository allowed to impersonate the service account via WIF (format: owner/repo)."
  type        = string
  default     = "nathanielhall/juice-shop"
}
