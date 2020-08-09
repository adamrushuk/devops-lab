# Service Principle for velero
resource "azuread_application" "velero_sp" {
  name = var.velero_service_principle_name
}

resource "azuread_service_principal" "velero_sp" {
  application_id = azuread_application.velero_sp.application_id
}

resource "random_string" "velero_sp" {
  length  = 16
  special = true
  keepers = {
    service_principal = azuread_service_principal.velero_sp.id
  }
}

resource "azuread_service_principal_password" "velero_sp" {
  service_principal_id = azuread_service_principal.velero_sp.id
  value                = random_string.velero_sp.result
  end_date_relative    = "8760h" # 8760h = 1 year

  lifecycle {
    ignore_changes = [end_date]
  }
}


# Service Principle role assignments
resource "azurerm_role_assignment" "velero_sp_to_sub" {
  principal_id                     = azuread_service_principal.velero_sp.id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_subscription.current.id
  skip_service_principal_aad_check = true
  depends_on                       = [azuread_service_principal_password.velero_sp]
}
