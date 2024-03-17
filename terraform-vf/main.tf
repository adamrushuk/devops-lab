resource "azurerm_management_group" "intermediary" {
  display_name = "intermediary"
  # 'Tenant Root Group' Management Group
  parent_management_group_id = "/providers/Microsoft.Management/managementGroups/d963d62c-d864-49fb-b3ba-6911db326ad2"
}

resource "azurerm_management_group" "local_market_1" {
  display_name               = "Local Market 1"
  parent_management_group_id = azurerm_management_group.intermediary.id
}

resource "azurerm_management_group" "local_market_2" {
  display_name               = "Local Market 2"
  parent_management_group_id = azurerm_management_group.intermediary.id
}
