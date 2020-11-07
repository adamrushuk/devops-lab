# nginx helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
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
