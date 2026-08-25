# CodeMender CLI GitHub Infrastructure

## Overview
This repository contains the Terraform configurations required to provision Google Cloud Workload Identity Federation (WIF). Its primary purpose is to establish keyless, secure authentication between GitHub Actions and Google Cloud, enabling the automated execution of the CodeMender CLI within target repositories. 

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
Once the infrastructure is configured, you can integrate CodeMender CLI using the following reusable starter configurations:
*   **Basic Scan:** Executes a standard scan, reporting findings and token usage. [View Basic Workflow](https://github.com/nathanielhall/the-most-vulnerable-dotnet-app/blob/main/.github/workflows/codemender_basic_scan.yml)
*   **ChatOps PR Generator:** Runs a scan and automatically generates an empty Pull Request populated with the identified findings. [View PR Workflow](https://github.com/nathanielhall/the-most-vulnerable-dotnet-app/blob/main/.github/workflows/codemender-findings-pr.yml)
*   **ChatOps Commands:** Listens for `/verify <ID>` or `/fix <ID>` comments on the generated PR to trigger targeted mitigation tasks. [View ChatOps Workflow](https://github.com/nathanielhall/the-most-vulnerable-dotnet-app/blob/main/.github/workflows/codemender-chatops.yml)

## Current Limitations & Optimization Paths
These starter workflows are designed for rapid onboarding and dynamic execution, which introduces certain constraints:
*   **Execution Overhead:** The CLI is currently installed dynamically on each workflow run. This creates latency and is inefficient when scaling against massive repositories.
*   **Containerization Constraints:** Transitioning to a pre-built container image would optimize runtime performance. However, this future improvement requires careful architectural planning to mitigate nested container execution issues within GitHub Actions.

