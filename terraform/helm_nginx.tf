# nginx helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "ingress" {
  metadata {
    # annotations = {
    #   name = "example-annotation"
    # }

    # labels = {
    #   mylabel = "label-value"
    # }

    name = "ingress"
  }
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nginx" {
  chart      = "nginx-ingress"
  name       = "nginx"
  namespace  = "ingress"
  repository = data.helm_repository.stable.metadata[0].name
  version    = "1.36.0"
  values     = ["${file("helm/nginx_values.yaml")}"]
}


resource "null_resource" "update_dns" {
  provisioner "local-exec" {
    command = "Update-Dns.ps1"
    environment = {
      aks_rg           = azurerm_kubernetes_cluster.aks.resource_group_name
      aks_cluster_name = azurerm_kubernetes_cluster.aks.name
      dns_domain_name  = var.dns_domain_name
      has_subdomain    = var.has_subdomain
      api_key          = var.api_key
      api_secret       = var.api_secret
    }
    interpreter = ["pwsh", "-NonInteractive", "-Command"]
    working_dir = "${path.module}/../scripts/"
  }
  depends_on = [helm_release.nginx]
}
