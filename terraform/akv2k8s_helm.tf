# Azure Key Vault to Kubernetes (akv2k8s) makes Azure Key Vault secrets, certificates and keys available in
# Kubernetes and/or your application - in a simple and secure way
#
# https://akv2k8s.io/
# https://github.com/SparebankenVest/azure-key-vault-to-kubernetes

# Key vault access policy for AKS / akv2k8s
data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

# Legacy key vault access policy method
# https://docs.microsoft.com/en-us/azure/key-vault/general/assign-access-policy-portal
# resource "azurerm_key_vault_access_policy" "aks" {
#   key_vault_id = data.azurerm_key_vault.kv.id

#   tenant_id = data.azurerm_subscription.current.tenant_id
#   object_id = module.aks.kubelet_identity[0].object_id

#   certificate_permissions = [
#     "get"
#   ]

#   key_permissions = [
#     "get"
#   ]

#   secret_permissions = [
#     "get"
#   ]
# }

# Provide key vault access to akv2k8s via Azure role-based access control
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "aks_mi_kv_certs" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = module.aks.kubelet_identity[0].object_id
  description          = "Perform any action on the keys of a key vault, except manage permissions"
}

resource "azurerm_role_assignment" "aks_mi_kv_keys" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = module.aks.kubelet_identity[0].object_id
  description          = "Perform cryptographic operations using keys"
}

resource "azurerm_role_assignment" "aks_mi_kv_secrets" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.kubelet_identity[0].object_id
  description          = "Provides read-only access to secret contents"
}

# Requires "kube_admin_config_raw" as has AAD Auth enabled
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#kube_admin_config_raw
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file
resource "local_sensitive_file" "kubeconfig" {
  content  = module.aks.full_object.kube_admin_config_raw
  filename = var.aks_config_path

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "akv2k8s" {
  metadata {
    name = "akv2k8s"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
# https://github.com/SparebankenVest/public-helm-charts/tree/master/stable/akv2k8s#configuration
resource "helm_release" "akv2k8s" {
  chart      = "akv2k8s"
  name       = "akv2k8s"
  namespace  = kubernetes_namespace.akv2k8s.metadata[0].name
  repository = "http://charts.spvapi.no"
  version    = var.akv2k8s_chart_version
  timeout    = 600
  atomic     = true

  set {
    name  = "addAzurePodIdentityException"
    value = "true"
  }

  set {
    name  = "controller.logLevel"
    value = "debug"
  }

  depends_on = [helm_release.aad_pod_identity]
}
