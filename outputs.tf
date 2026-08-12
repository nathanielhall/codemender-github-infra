output "WIF_SERVICE_ACCOUNT" {
  description = "The email address of the created Google Cloud Service Account."
  value       = google_service_account.github_sa.email
}

output "WIF_PROVIDER" {
  description = "The full resource name of the Workload Identity Provider."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}
