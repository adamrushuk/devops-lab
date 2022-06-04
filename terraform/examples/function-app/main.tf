# function app example

# providers
provider "azurerm" {
  features {}
}
terraform {
  required_version = ">= 1.0"
  required_providers {
    # https://github.com/terraform-providers/terraform-provider-azurerm/releases
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.8.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }
}

locals {
  region                 = "uksouth"
  resource_group_name    = "az-func-example"
  storage_account_name   = "arlinuxfunctionappps"
  storage_container_name = "function-releases"
  app_service_plan_name  = "example-app-service-plan"
  function_app_name      = "arush-linux-function-app"
  function_source_path   = "./functions"
  function_name          = "HttpTrigger1"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.region
}

resource "azurerm_storage_account" "example" {
  name                      = local.storage_account_name
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
}

resource "azurerm_storage_container" "example" {
  name                  = local.storage_container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

data "archive_file" "example" {
  type        = "zip"
  source_dir  = local.function_source_path
  output_path = "function_release.zip"
}

resource "azurerm_storage_blob" "example" {
  # The name of the file will be "filehash.zip" where file hash is the SHA256 hash of the file.
  name                   = "${filesha256(data.archive_file.example.output_path)}.zip"
  source                 = data.archive_file.example.output_path
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
}

resource "azurerm_service_plan" "example" {
  name                = local.app_service_plan_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "example" {
  name                          = local.function_app_name
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  enabled                       = true
  storage_account_name          = azurerm_storage_account.example.name
  service_plan_id               = azurerm_service_plan.example.id
  storage_uses_managed_identity = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    # vnet_route_all_enabled   = true
    # application_insights_key = azurerm_application_insights.application_insights.instrumentation_key
    # http2_enabled            = true

    application_stack {
      powershell_core_version = 7.2
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = azurerm_storage_blob.example.url
  }

  lifecycle {
    # required to ignore the auto-generated "hidden-link:" tags
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "example" {
  principal_id         = azurerm_linux_function_app.example.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.example.id
}

output "function" {
  value     = azurerm_linux_function_app.example
  sensitive = true
}

output "function_url" {
  value = "https://${azurerm_linux_function_app.example.name}.azurewebsites.net/api/${local.function_name}"
}
