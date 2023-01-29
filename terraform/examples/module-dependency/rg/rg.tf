variable "object_id" {
  default = ""
}

resource "azurerm_resource_group" "example" {
  count    = var.object_id == "" ? 0 : 1
  name     = var.object_id
  location = "uksouth"
}
