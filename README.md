<!-- omit in toc -->
# aks-nexus-velero

[![Build environment](https://github.com/adamrushuk/aks-nexus-velero/workflows/build/badge.svg)](https://github.com/adamrushuk/aks-nexus-velero/actions?query=workflow%3A%22build)

This is the main repo I use to test Kubernetes /  DevOps applications, products, and processes. It's essentially my
playground in Azure.

I started off with a Kubernetes cluster, Nexus Repository OSS, and Velero  for backups, but there are *loads* more
being used now.

<!-- omit in toc -->
## Contents

- [Getting Started](#getting-started)
  - [Configure Azure Authentication](#configure-azure-authentication)
  - [Create Secrets](#create-secrets)
  - [Running the Build workflow](#running-the-build-workflow)

## Getting Started

Before the [`build`](./.github/workflows/build.yml) GitHub Action workflow can be run, authentication needs to be
configured for Azure.

### Configure Azure Authentication

1. [Create a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#creating-the-application-and-service-principal).

1. [Grant permissions to manage Azure Active Directory](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration#azure-active-directory-permissions).

### Create Secrets

Once Azure authentication has been configured, the Service Principle credential values can be [passed as environment variables](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform).

[Use these instructions](https://docs.github.com/en/free-pro-team@latest/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) to create the following secrets for your repository:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

### Running the Build workflow

Now that Azure authentication has been configured with corresponding secrets, the build workflow is ready to be run:

1. Navigate to the [build workflow](../../actions?query=workflow%3Abuild).
1. Click the `Run workflow` drop-down button.
1. Select the desired branch.
1. Click the `Run workflow` button.
