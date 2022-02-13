# testing module dependency
data "azurerm_subscription" "current" {}

resource "azuread_group" "elevated_group" {
  display_name            = "${data.azurerm_subscription.current.display_name}_Elevated_Ops"
  security_enabled        = true
  prevent_duplicate_names = true
}

output "aad_elevated_group" {
  value       = azuread_group.elevated_group.id
  description = "Id of the AAD Elevated Ops group for the subscription"
}

output "aad_group_name" {
  value       = azuread_group.elevated_group.display_name
  description = "Id of the AAD Elevated Ops group for the subscription"
}
