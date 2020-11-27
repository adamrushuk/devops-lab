# WARNING: this outputs credential / login config
# output "aks_config" {
#   value = module.aks
# }

output "aks_credentials_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.aks.name} --name ${module.aks.name} --overwrite-existing"
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

# output "ssh_private_key" {
#   value     = tls_private_key.ssh.private_key_pem
#   sensitive = true
# }

# output "ssh_public_key" {
#   value = tls_private_key.ssh.public_key_openssh
# }

# output "ssh_public_key_pem" {
#   value = tls_private_key.ssh.public_key_pem
# }

# output "client_certificate" {
#   value = module.aks.kube_config[0].client_certificate
# }

# output "kube_config" {
#   value = module.aks.kube_config_raw
# }
