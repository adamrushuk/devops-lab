# Azure Key Vault to Kubernetes (akv2k8s) makes Azure Key Vault secrets, certificates and keys available in
# Kubernetes and/or your application - in a simple and secure way
#
# https://akv2k8s.io/
# https://github.com/SparebankenVest/azure-key-vault-to-kubernetes


# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "akv2k8s_crds" {
  # triggers = {
  #   always_run = "${timestamp()}"
  # }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/sparebankenvest/azure-key-vault-to-kubernetes/crd-1.1.0/crds/AzureKeyVaultSecret.yaml"
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
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

# https://www.terraform.io/docs/providers/helm/r/release.html
# https://github.com/SparebankenVest/public-helm-charts/tree/master/stable/akv2k8s#configuration
resource "helm_release" "akv2k8s" {
  chart      = "akv2k8s"
  name       = "akv2k8s"
  namespace  = "akv2k8s"
  repository = "http://charts.spvapi.no"
  version    = var.akv2k8s_chart_version
  timeout    = 600
  depends_on = [kubernetes_namespace.akv2k8s]
}
