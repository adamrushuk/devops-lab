# Function App for reporting on VMs left running outside allowed time range
resource "azurerm_resource_group" "func_app" {
  name     = "${var.prefix}-rg-function-app"
  location = var.location
  tags     = var.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "func_app" {
  name                            = "${var.prefix}stfuncapp"
  resource_group_name             = azurerm_resource_group.func_app.name
  location                        = azurerm_resource_group.func_app.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
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
  name                   = "${filesha256(data.archive_file.example.output_path)}.zip"
  storage_account_name   = azurerm_storage_account.func_app.name
  storage_container_name = azurerm_storage_container.func_app.name
  source                 = data.archive_file.func_app.output_path
  type                   = "Block"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
resource "azurerm_service_plan" "func_app" {
  name                = "${var.prefix}-funcapp"
  location            = azurerm_resource_group.func_app.location
  resource_group_name = azurerm_resource_group.func_app.name
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

# Application Insights used for logs and monitoring
resource "azurerm_application_insights" "appinsights" {
  name                = "${var.prefix}-funcapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.func_app.name
  application_type    = "web"
  tags                = var.tags
}

# Function App using zipped up source files
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app
resource "azurerm_linux_function_app" "func_app" {
  name                          = "${var.prefix}-funcapp"
  location                      = azurerm_resource_group.func_app.location
  resource_group_name           = azurerm_resource_group.func_app.name
  service_plan_id               = azurerm_service_plan.func_app.id
  storage_account_access_key    = azurerm_storage_account.func_app.primary_access_key
  storage_account_name          = azurerm_storage_account.func_app.name
  storage_uses_managed_identity = true
  tags                          = var.tags
  # enabled                       = true
  # https_only                    = true

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
    # "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsights.instrumentation_key
    # "FUNCTIONS_WORKER_RUNTIME_VERSION" = "~7"
    # "FUNCTIONS_WORKER_RUNTIME"         = "powershell"
    # "FUNCTION_APP_EDIT_MODE"           = "readonly"
    # "HASH"                             = base64encode(filesha256("${path.module}/files/function_app.zip"))
    # "WEBSITE_RUN_FROM_PACKAGE"   = "https://${azurerm_storage_account.func_app.name}.blob.core.windows.net/${azurerm_storage_container.func_app.name}/${azurerm_storage_blob.func_app.name}${data.azurerm_storage_account_sas.func_app.sas}"
    "WEBSITE_RUN_FROM_PACKAGE"   = azurerm_storage_blob.func_app.url
    "IFTTT_WEBHOOK_KEY"          = var.ifttt_webhook_key
    "WEEKDAY_ALLOWED_TIME_RANGE" = "06:30 -> 09:00"
  }
}

# Give Function App access to function zip blob
resource "azurerm_role_assignment" "func_app_storage" {
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.example.id
}

# Give Function App Reader role for the AKS cluster node resource group
resource "azurerm_role_assignment" "func_app_aks" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
}
