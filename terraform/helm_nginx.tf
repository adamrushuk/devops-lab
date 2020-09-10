# nginx helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
  timeouts {
    delete = "15m"
  }
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nginx" {
  chart      = "ingress-nginx"
  name       = "nginx"
  namespace  = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = var.nginx_chart_version
  values     = ["${file("helm/nginx_values.yaml")}"]
  timeout    = 600
  depends_on = [kubernetes_namespace.ingress]
}

# ? Removed as now using kubernetes external-dns
# ? keeping for reference of dns update script usage
# https://www.terraform.io/docs/provisioners/local-exec.html
# resource "null_resource" "update_dns" {
#   # triggers = {
#   #   always_run = "${timestamp()}"
#   # }

#   provisioner "local-exec" {
#     command = "./Update-Dns.ps1"
#     environment = {
#       aks_rg           = azurerm_kubernetes_cluster.aks.resource_group_name
#       aks_cluster_name = azurerm_kubernetes_cluster.aks.name
#       dns_domain_name  = var.dns_domain_name
#       has_subdomain    = var.has_subdomain
#       api_key          = var.api_key
#       api_secret       = var.api_secret
#     }
#     interpreter = ["pwsh", "-NonInteractive", "-Command"]
#     working_dir = "${path.module}/../scripts/"
#   }
#   depends_on = [helm_release.nginx]
# }
