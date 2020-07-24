# Function App for reporting on VMs left running outside allowed time range
resource "azurerm_resource_group" "func_app" {
  name     = "rg-function-app"
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "func_app" {
  name                     = "${var.prefix}stfuncapp"
  resource_group_name      = azurerm_resource_group.func_app.name
  location                 = azurerm_resource_group.func_app.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_storage_container" "func_app" {
  name                  = "${var.prefix}-function-apps"
  storage_account_name  = azurerm_storage_account.func_app.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "func_app" {
  name                   = "function_app.zip"
  storage_account_name   = azurerm_storage_account.func_app.name
  storage_container_name = azurerm_storage_container.func_app.name
  type                   = "Block"
  source                 = "${path.module}/files/function_app.zip"
}

data "azurerm_storage_account_sas" "func_app" {
  connection_string = azurerm_storage_account.func_app.primary_connection_string
  https_only        = true
  start             = formatdate("YYYY-MM-DD", timestamp())
  expiry            = formatdate("YYYY-MM-DD", timeadd(timestamp(), var.func_app_sas_expires_in_hours))

  resource_types {
    object    = true
    container = false
    service   = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}

resource "azurerm_app_service_plan" "func_app" {
  name                = "${var.prefix}-funcapp"
  location            = azurerm_resource_group.func_app.location
  resource_group_name = azurerm_resource_group.func_app.name
  # reserved            = false # This needs to be set as 'false' otherwise the default is a Linux function app which won't work with our code
  kind                = "FunctionApp"
  tags                = var.tags

  # Consumption Plan
  sku {
    tier = "Dynamic"
    size = "Y1"
  }

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
resource "azurerm_function_app" "func_app" {
  name                       = "${var.prefix}-funcapp"
  location                   = azurerm_resource_group.func_app.location
  resource_group_name        = azurerm_resource_group.func_app.name
  app_service_plan_id        = azurerm_app_service_plan.func_app.id
  storage_account_name       = azurerm_storage_account.func_app.name
  storage_account_access_key = azurerm_storage_account.func_app.primary_access_key
  version                    = "~3"
  tags                       = var.tags
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"   = azurerm_application_insights.appinsights.instrumentation_key
    "FUNCTION_APP_EDIT_MODE"           = "readonly"
    "FUNCTIONS_WORKER_RUNTIME_VERSION" = "~7"
    "FUNCTIONS_WORKER_RUNTIME"         = "powershell"
    "HASH"                             = base64encode(filesha256("${path.module}/files/function_app.zip"))
    "IFTTT_WEBHOOK_KEY"                = var.ifttt_webhook_key
    "WEBSITE_RUN_FROM_PACKAGE"         = "https://${azurerm_storage_account.func_app.name}.blob.core.windows.net/${azurerm_storage_container.func_app.name}/${azurerm_storage_blob.func_app.name}${data.azurerm_storage_account_sas.func_app.sas}"
    "WEEKDAY_ALLOWED_TIME_RANGE"       = "06:30 -> 09:00"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings,
    ]
  }
}

# Give Function App Reader role for the AKS cluster node resource group
# resource "azurerm_role_assignment" "func_app" {
#   scope                = azurerm_kubernetes_cluster.aks.node_resource_group
#   role_definition_name = "Reader"
#   principal_id         = azurerm_function_app.func_app.identity.0.principal_id
# }
