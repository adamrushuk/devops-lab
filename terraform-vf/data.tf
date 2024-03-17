data "azuread_client_config" "current" {}

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application_published_app_ids
data "azuread_application_published_app_ids" "well_known" {}
