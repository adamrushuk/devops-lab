output "aks_config" {
  value = azurerm_kubernetes_cluster.aks
}

output "aks_browse_command" {
  value = "az aks browse --resource-group ${azurerm_kubernetes_cluster.aks.resource_group_name} --name ${azurerm_kubernetes_cluster.aks.name}"
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
#   value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw
# }
