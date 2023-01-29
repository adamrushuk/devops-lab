# test modifying a role def after a role assignment exists

# providers
provider "azurerm" {
  features {}
}
terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.86.0"
    }
  }
}

# vars
variable "nsg_rights_enabled" {
  description = "additional rights for nsg usage"
  default     = false
}

locals {
  default_custom_not_actions = [
    "Microsoft.Authorization/*/Delete",
    "Microsoft.Authorization/*/Write",
    "Microsoft.Authorization/elevateAccess/Action",
    "Microsoft.Blueprint/blueprintAssignments/delete",
    "Microsoft.Blueprint/blueprintAssignments/write",
    "Microsoft.Network/networkSecurityGroups/delete",
    "Microsoft.Network/networkSecurityGroups/join/action",
    "Microsoft.Network/networkSecurityGroups/securityRules/delete",
    "Microsoft.Network/networkSecurityGroups/securityRules/write",
    "Microsoft.Network/networkSecurityGroups/write",
    "Microsoft.Network/publicIPAddresses/delete",
    "Microsoft.Network/publicIPAddresses/join/action",
    "Microsoft.Network/publicIPAddresses/write",
    "Microsoft.Network/publicIPPrefixes/delete",
    "Microsoft.Network/publicIPPrefixes/join/action",
    "Microsoft.Network/publicIPPrefixes/write",
    "Microsoft.Network/routeTables/*/delete",
    "Microsoft.Network/routeTables/*/write",
    "Microsoft.Network/virtualNetworks/*/delete",
    "Microsoft.Network/virtualNetworks/*/write",
    "Microsoft.Subscription/cancel/action",
    "Microsoft.Subscription/rename/action",
  ]

  nsg_rights_allowed_actions = [
    "Microsoft.Network/networkSecurityGroups/delete",
    "Microsoft.Network/networkSecurityGroups/join/action",
    "Microsoft.Network/networkSecurityGroups/securityRules/delete",
    "Microsoft.Network/networkSecurityGroups/securityRules/write",
    "Microsoft.Network/networkSecurityGroups/write",
  ]

  nsg_custom_not_actions = tolist(setsubtract(local.default_custom_not_actions, local.nsg_rights_allowed_actions))
}

# data sources
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}



# resources
resource "azurerm_role_definition" "custom" {
  name  = "Test-Role"
  scope = data.azurerm_subscription.current.id

  permissions {
    actions = [
      "Microsoft.Blueprint/blueprintAssignments/write",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Blueprint/blueprintAssignments/delete",
      "Microsoft.Resources/subscriptions/resourceGroups/write",
    ]

    # not_actions = var.nsg_rights_enabled ? local.nsg_custom_not_actions : local.default_custom_not_actions
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id,
  ]
}

resource "azurerm_role_assignment" "custom" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.custom.role_definition_resource_id
  #   principal_id       = data.azurerm_client_config.current.client_id
  principal_id = "577321c0-cff2-4d20-b29e-5e775942b32a"
}
