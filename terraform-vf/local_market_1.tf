resource "azuread_users" "lm1_users" {
  user_principal_name = ["localmarket1user@thehypepipe.co.uk"]
  display_name        = "localmarket1user"
}

resource "azuread_users" "lm1_admins" {
  user_principal_name = ["localmarket1admin@thehypepipe.co.uk"]
  display_name        = "localmarket1user"
}

resource "azuread_group" "lm1_users" {
  display_name            = "LM1 Users"
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true
  security_enabled        = true
  members                 = data.azuread_users.lm1_users.object_ids
}

resource "azuread_group" "lm1_admins" {
  display_name            = "LM1 Admins"
  owners                  = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names = true
  security_enabled        = true
  assignable_to_role      = true
  members                 = data.azuread_users.lm1_admins.object_ids
}

resource "azuread_administrative_unit" "lm1" {
  display_name              = "Local Market 1"
  description               = "Local Market 1"
  hidden_membership_enabled = false
}

resource "azuread_administrative_unit_member" "lm1_users" {
  for_each                      = toset(data.azuread_users.lm1_users.object_ids)
  administrative_unit_object_id = azuread_administrative_unit.lm1.id
  member_object_id              = each.value
}

resource "azuread_administrative_unit_member" "lm1_user_group" {
  administrative_unit_object_id = azuread_administrative_unit.lm1.id
  member_object_id              = azuread_group.lm1_users.id
}

# List of roles can be found here
# https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference
resource "azuread_directory_role" "lm1_user_administrator" {
  display_name = "User Administrator"
}

resource "azuread_administrative_unit_role_member" "lm1_user_administrator" {
  role_object_id                = azuread_directory_role.lm1_user_administrator.object_id
  administrative_unit_object_id = azuread_administrative_unit.lm1.id
  member_object_id              = azuread_group.lm1_admins.object_id
}

resource "azurerm_role_assignment" "lm1_reader_sub_access" {
  scope                = "/subscriptions/d57a223f-3332-42ff-84a0-85afb8f11c8b" # Hardcoded to vf-grp-tsa-prd-devops-01
  role_definition_name = "Reader"
  principal_id         = azuread_group.lm1_users.object_id
}
