# Google Cloud Workload Identity Federation for GitHub Actions

This Terraform project provisions Google Cloud Workload Identity Federation (WIF) infrastructure to enable keyless authentication for GitHub Actions workflows interacting with GCP services (e.g., CodeMender backend APIs on Vertex AI).

## Overview

Keyless authentication via Workload Identity Federation eliminates the need to store long-lived service account key JSON files in GitHub Secrets. Instead, GitHub Actions requests a short-lived OIDC token from GitHub, which Google Cloud exchanges for a short-lived GCP access token based on trust rules configured in this repository.

## Resources Provisioned

1. **Google Cloud Service Account** (`google_service_account`):
   - Service account impersonated by GitHub Actions runners.
2. **Project IAM Role Assignment** (`google_project_iam_member`):
   - Grants `roles/aiplatform.user` to the service account so it can call Vertex AI / CodeMender backend APIs.
3. **Workload Identity Pool** (`google_iam_workload_identity_pool`):
   - Manages identity mappings between GitHub Actions OIDC tokens and GCP identities.
4. **Workload Identity Provider** (`google_iam_workload_identity_pool_provider`):
   - Configured with GitHub OIDC issuer (`https://token.actions.githubusercontent.com`).
   - Attribute Mappings:
     - `google.subject` = `assertion.sub`
     - `attribute.repository` = `assertion.repository`
5. **WIF Service Account Trust Binding** (`google_service_account_iam_member`):
   - Grants `roles/iam.workloadIdentityUser` to the GitHub repository restricted by `attribute.repository` (default: `nathanielhall/juice-shop`).

## Prerequisites

- [Terraform](https://www.terraform.io/) >= 1.0.0
- Google Cloud SDK (`gcloud`) installed and authenticated
- A GCP project with the necessary APIs enabled:
  - IAM Service Account API (`iam.googleapis.com`)
  - Security Token Service API (`sts.googleapis.com`)
  - IAM Credentials API (`iamcredentials.googleapis.com`)
  - Vertex AI API (`aiplatform.googleapis.com`)

## Usage

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Plan Infrastructure Deployment

Provide your GCP Project ID when prompted or via a `terraform.tfvars` file:

```bash
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID"
```

### 3. Apply Infrastructure Changes

```bash
terraform apply -var="project_id=YOUR_GCP_PROJECT_ID"
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :---: |
| `project_id` | The GCP project ID where WIF resources will be provisioned. | `string` | N/A | **Yes** |
| `region` | The default GCP region. | `string` | `"us-central1"` | No |
| `workload_identity_pool_id` | The ID of the Workload Identity Pool. | `string` | `"github-actions-pool"` | No |
| `workload_identity_provider_id` | The ID of the Workload Identity Pool Provider. | `string` | `"github-actions-provider"` | No |
| `service_account_id` | The account ID for the Google Cloud Service Account. | `string` | `"codemender-github-sa"` | No |
| `github_repository` | The GitHub repository allowed to impersonate the service account (`owner/repo`). | `string` | `"nathanielhall/juice-shop"` | No |

## Outputs

| Name | Description |
| :--- | :--- |
| `WIF_SERVICE_ACCOUNT` | The email address of the created Service Account. |
| `WIF_PROVIDER` | The full resource name of the Workload Identity Provider. |

## GitHub Actions Integration

After running `terraform apply`, copy the values from `WIF_SERVICE_ACCOUNT` and `WIF_PROVIDER` into your GitHub repository secrets or environment variables.

Example workflow step using [`google-github-actions/auth`](https://github.com/google-github-actions/auth):

```yaml
name: CodeMender Pipeline

on:
  push:
    branches: [ main ]

jobs:
  codemender:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # Required for requesting the JWT OIDC token

    steps:
    - name: Checkout Code
      uses: actions/checkout@v4

    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: '${{ secrets.WIF_PROVIDER }}'
        service_account: '${{ secrets.WIF_SERVICE_ACCOUNT }}'

    # Subsequent steps now run with authenticated GCP credentials
```
