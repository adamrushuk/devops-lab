<!-- omit in toc -->
# aks-nexus-velero

[![Build environment](https://github.com/adamrushuk/aks-nexus-velero/workflows/build/badge.svg)](https://github.com/adamrushuk/aks-nexus-velero/actions?query=workflow%3A%22build)

This is the main repo I use to test Kubernetes /  DevOps applications, products, and processes. It's basically my playground.

I started off with a Kubernetes cluster, Nexus Repository OSS, and Velero  for backups, but there's loads more being used now.

<!-- omit in toc -->
## Contents

- [Getting Started](#getting-started)
  - [Assumptions](#assumptions)
  - [Azure Secrets](#azure-secrets)

## Getting Started

Before you start the `build` GitHub Action workflow, you need to create the following Secrets within
[GitHub Settings](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets):

### Assumptions

<!-- TODO -->

- Configure Azure Service Principle for Terraform, and grant permission to manage AAD:
https://www.terraform.io/docs/providers/azuread/guides/service_principal_configuration.html#granting-administrator-permissions

These API permissions are required for your Terraform Service Principle:

**Azure Active Directory Graph**
Application Permissions:

1. Application.ReadWrite.All - Read and write all applications
1. Directory.Read.All - Read directory data

Delegated Permissions:

1. User.Read - Sign in and read user profile

### Azure Secrets

<!-- TODO -->

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
