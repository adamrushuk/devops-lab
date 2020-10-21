# role assignment for aad-pod-identity / velero auth
resource "azurerm_role_assignment" "aks_msi_aks_node_rg" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "Contributor"
  scope                            = data.azurerm_resource_group.aks.id
  skip_service_principal_aad_check = true
}
