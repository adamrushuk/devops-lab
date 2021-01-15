# nginx helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nginx" {
  chart      = "ingress-nginx"
  name       = "nginx"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = var.nginx_chart_version
  timeout    = 600
  values     = ["${file("helm/nginx_values.yaml")}"]
}

# wait /fix for documented warning
# https://kubernetes.github.io/ingress-nginx/deploy/
# The first time the ingress controller starts, two Jobs create the SSL Certificate used by the admission webhook.
# For this reason, there is an initial delay of up to two minutes until it is possible to create and validate Ingress
# definitions.
resource "null_resource" "nginx_ready" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
    }

    command     = <<EOT
      kubectl wait --namespace ingress \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=120s
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    helm_release.nginx
  ]
}
