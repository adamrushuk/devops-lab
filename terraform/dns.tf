# DNS
resource "azurerm_resource_group" "dns" {
  name     = var.dns_resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_dns_zone" "dns" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.dns.name
  name_servers        = var.dns_name_servers
}
