<!-- omit in toc -->
# aks-nexus-velero

[![Build environment](https://github.com/adamrushuk/aks-nexus-velero/workflows/build/badge.svg)](https://github.com/adamrushuk/aks-nexus-velero/actions?query=workflow%3A%22build)

This is the main repo I use to test Kubernetes /  DevOps applications, products, and processes. It's essentially my
playground in Azure.

I started off with a Kubernetes cluster, Nexus Repository OSS, and Velero for backups, but there are *loads* more
being used now.

<!-- omit in toc -->
## Contents

- [Getting Started](#getting-started)
  - [Prereqs](#prereqs)
    - [Configure DNS Zone](#configure-dns-zone)
    - [Configure Key Vault / LetsEncrypt TLS Certificate](#configure-key-vault--letsencrypt-tls-certificate)
  - [Configure Azure Authentication](#configure-azure-authentication)
  - [Create Secrets](#create-secrets)
  - [Running the Build workflow](#running-the-build-workflow)
  - [Running the Destroy workflow](#running-the-destroy-workflow)

## Getting Started

Follow the sections below to prepare and configure your environment, ready to run your first build:

### Prereqs

DNS zones and TLS certs are typically created out-of-band (outside of the main build automation), so we'll create
these only once, and they will exist across multiple builds.

#### Configure DNS Zone

Use the [Setting up ExternalDNS for Services on Azure tutorial](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/azure.md)
 to create and configure your DNS zone, as we will be using ExternalDNS within the kubernetes cluster to
dynamically update DNS records.

#### Configure Key Vault / LetsEncrypt TLS Certificate

Use the [keyvault-acmebot Getting Started guide](https://github.com/shibayan/keyvault-acmebot#getting-started) to
deploy AcmeBot and configure a wildcard certificate for your domain.

### Configure Azure Authentication

Before the [`build`](./.github/workflows/build.yml) GitHub Action workflow can be run, authentication needs to be
configured for Azure.

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

### Running the Destroy workflow

There will be ongoing costs if the environment is left running, so to avoid unexpected bills the destroy workflow
should be run once testing has been completed:

1. Navigate to the [destroy workflow](../../actions?query=workflow%3Adestroy).
1. Click the `Run workflow` drop-down button.
1. Select the desired branch.
1. Click the `Run workflow` button.
