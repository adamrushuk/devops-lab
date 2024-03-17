data "azuread_user" "example" {
  user_principal_name = "admin@adamrushukoutlook.onmicrosoft.com"
}

resource "azuread_administrative_unit" "example" {
  display_name = "Example-AU"
}

resource "azuread_administrative_unit_member" "example" {
  administrative_unit_object_id = azuread_administrative_unit.example.id
  member_object_id              = data.azuread_user.example.id
}

resource "azuread_group" "lm1_users" {
  display_name            = "LM1 Users"
#   prevent_duplicate_names = true
  security_enabled        = true
#   members                 = data.azuread_users.lm1_users.object_ids
}

resource "azuread_administrative_unit_member" "lm1_user_group" {
  administrative_unit_object_id = azuread_administrative_unit.example.id
  member_object_id              = azuread_group.lm1_users.id
}
