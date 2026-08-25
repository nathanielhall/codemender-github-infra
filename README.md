# CodeMender + GitHub: Infra & Workflows

## Infrastructure Setup
Before utilizing the CodeMender workflows, the foundational authentication and repository settings must be established.

**1. Google Cloud Configuration (Terraform)**
This repository automates the creation of a Workload Identity Pool, a GitHub-specific Provider, and a Service Account with the necessary IAM bindings. 
*   Initialize and apply the Terraform configurations found in this repository to your target GCP project.
*   For a deeper dive into the mechanics of this setup, reference this [Workload Identity Federation Guide](https://www.firefly.ai/academy/setting-up-workload-identity-federation-between-github-actions-and-google-cloud-platform).

**2. GitHub Repository Secrets**
Once Terraform has provisioned the infrastructure, the resulting outputs must be mapped to your target repository's secrets (**Settings > Secrets and variables > Actions**):
*   `WIF_PROVIDER`: The full path of the created WIF provider.
*   `WIF_SERVICE_ACCOUNT`: The email address of the provisioned GCP Service Account.

**3. GitHub Actions Settings**
Ensure your target repository is permitted to execute workflows and manage Pull Requests (**Settings > Actions > General**):
*   **Actions permissions:** Enable "Allow all actions and reusable workflows."
*   **Workflow permissions:** Enable "Read and write permissions" to allow ChatOps workflows to generate and update PRs.


## Example Workflows
This repository includes a curated list of reusable GitHub Actions templates, ranging from basic vulnerability scanning to advanced ChatOps remediation and bulk fixes. 

For a complete list of available templates, their specific triggers, and usage instructions, please see the **[Example Workflows Documentation](./example-workflows/README.md)**.

## Current Limitations & Optimization Paths
These starter workflows are designed for rapid onboarding and dynamic execution, which introduces certain constraints:
*   **Execution Overhead:** The CLI is currently installed dynamically on each workflow run. This creates latency and is inefficient when scaling against massive repositories.
*   **Containerization Constraints:** Transitioning to a pre-built container image would optimize runtime performance. However, this future improvement requires careful architectural planning to mitigate nested container execution issues within GitHub Actions.

