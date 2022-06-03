# Function App for reporting on VMs left running outside allowed time range

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "func_app" {
  name                            = "${var.prefix}stfuncapp"
  resource_group_name             = azurerm_resource_group.aks.name
  location                        = azurerm_resource_group.aks.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = var.tags
}

resource "azurerm_storage_container" "func_app" {
  name                  = "${var.prefix}-function-apps"
  storage_account_name  = azurerm_storage_account.func_app.name
  container_access_type = "private"
}

data "archive_file" "func_app" {
  type        = "zip"
  source_dir  = "${path.module}/../function_app"
  output_path = "function_release.zip"
}

resource "azurerm_storage_blob" "func_app" {
  # name will be "[filehash].zip" (filehash is the SHA256 hash of the file)
  name                   = "${filesha256(data.archive_file.func_app.output_path)}.zip"
  storage_account_name   = azurerm_storage_account.func_app.name
  storage_container_name = azurerm_storage_container.func_app.name
  source                 = data.archive_file.func_app.output_path
  type                   = "Block"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
resource "azurerm_service_plan" "func_app" {
  name                = "${var.prefix}-funcapp"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

# Application Insights used for logs and monitoring
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}-funcapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.aks[0].id
  tags                = var.tags
}

# Function App using zipped up source files
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app
resource "azurerm_linux_function_app" "func_app" {
  name                          = "${var.prefix}-funcapp"
  location                      = azurerm_resource_group.aks.location
  resource_group_name           = azurerm_resource_group.aks.name
  service_plan_id               = azurerm_service_plan.func_app.id
  storage_account_name          = azurerm_storage_account.func_app.name
  storage_uses_managed_identity = true
  enabled                       = true
  https_only                    = true
  tags                          = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app#application_insights_key
    application_insights_key = azurerm_application_insights.appinsights.instrumentation_key

    application_stack {
      powershell_core_version = 7.2
    }
  }

  # https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  app_settings = {
    # The Function app will only use the code in the blob if the computed hash matches the hash you specify in the app settings. The computed hash takes the SHA256 hash of the file and then base64 encodes it
    # "HASH"                       = base64encode(filesha256("${path.module}/files/function_app.zip"))
    "FUNCTION_APP_EDIT_MODE"     = "readwrite"
    "WEBSITE_RUN_FROM_PACKAGE"   = azurerm_storage_blob.func_app.url
    "IFTTT_WEBHOOK_KEY"          = var.ifttt_webhook_key
    "WEEKDAY_ALLOWED_TIME_RANGE" = "06:30 -> 09:00"
  }
}

# Give Function App access to function zip blob
resource "azurerm_role_assignment" "func_app_storage" {
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.func_app.id
}

# Give Function App Reader role for the AKS cluster node resource group
resource "azurerm_role_assignment" "func_app_aks" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
}
