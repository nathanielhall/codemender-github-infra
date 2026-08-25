# 0. Required Google Cloud APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# 1. Service Account
resource "google_service_account" "github_sa" {
  account_id   = var.service_account_id
  display_name = "GitHub Actions Service Account"
  description  = "Service account impersonated by GitHub Actions runners for CodeMender"
  project      = var.project_id

  depends_on = [google_project_service.required_apis]
}

# 2. Service Account Permissions
resource "google_project_iam_member" "aiplatform_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.github_sa.email}"

  depends_on = [google_project_service.required_apis]
}

# 3. Workload Identity Pool
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions pipeline"
  project                   = var.project_id

  depends_on = [google_project_service.required_apis]
}

# 4. Workload Identity Provider
resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC identity provider for GitHub Actions"
  project                            = var.project_id

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_project_service.required_apis]
}

# 5. WIF Trust Binding
resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.github_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repository}"

  depends_on = [google_project_service.required_apis]
}
