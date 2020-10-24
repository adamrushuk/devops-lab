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

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = data.azurerm_key_vault.kv.id

  tenant_id = data.azurerm_subscription.current.tenant_id
  object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  certificate_permissions = [
    "get"
  ]

  key_permissions = [
    "get"
  ]

  secret_permissions = [
    "get"
  ]
}


resource "local_file" "kubeconfig" {
  sensitive_content = azurerm_kubernetes_cluster.aks.kube_config_raw
  filename          = var.aks_config_path

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "akv2k8s_crds" {
  triggers = {
    # always_run = "${timestamp()}"
    akv2k8s_yaml_contents           = filemd5(var.akv2k8s_yaml_path)
    cert_sync_yaml_contents         = filemd5(var.cert_sync_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      export KUBECONFIG=${var.aks_config_path}
      # TODO: is this needed, or do CRDs install by default?
      # https://helm.sh/docs/chart_best_practices/custom_resource_definitions/
      # kubectl apply -f ${var.akv2k8s_yaml_path}
      kubectl apply -f ${var.cert_sync_yaml_path}
    EOT
  }

  depends_on = [local_file.kubeconfig]
}

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "akv2k8s" {
  metadata {
    name = "akv2k8s"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [null_resource.akv2k8s_crds]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "akv2k8s_exceptions" {
  triggers = {
    # always_run = "${timestamp()}"
    akv2k8s_exception_yaml_contents = filemd5(var.akv2k8s_exception_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      export KUBECONFIG=${var.aks_config_path}
      kubectl apply -f ${var.akv2k8s_exception_yaml_path}
    EOT
  }

  depends_on = [local_file.kubeconfig, kubernetes_namespace.akv2k8s]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
# https://github.com/SparebankenVest/public-helm-charts/tree/master/stable/akv2k8s#configuration
resource "helm_release" "akv2k8s" {
  chart      = "akv2k8s"
  name       = "akv2k8s"
  namespace  = "akv2k8s"
  repository = "http://charts.spvapi.no"
  version    = var.akv2k8s_chart_version

  set {
    name  = "logLevel"
    value = "debug"
  }

  timeout    = 600
  depends_on = [kubernetes_namespace.akv2k8s]
}
