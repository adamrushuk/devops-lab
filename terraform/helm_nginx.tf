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
  values     = ["${file("nginx/nginx_values.yaml")}"]
}
