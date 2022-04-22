# argocd helm chart
# https://argoproj.github.io/argo-cd/

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "argocd_cert_sync" {
  triggers = {
    # always_run = "${timestamp()}"
    cert_sync_yaml_contents = filemd5(var.argocd_cert_sync_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
    }
    command = <<-EOT
      kubectl apply -f ${var.argocd_cert_sync_yaml_path}
    EOT
  }

  depends_on = [
    local_sensitive_file.kubeconfig,
    helm_release.akv2k8s,
    kubernetes_namespace.argocd
  ]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  version    = var.argocd_chart_version
  timeout    = 600
  atomic     = true
  values     = [file("${path.module}/files/argocd-values.yaml")]

  set {
    name  = "global.image.tag"
    value = var.argocd_image_tag
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = "argocd.${var.dns_zone_name}"
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-ingress-tls"
  }

  # Argo CD's externally facing base URL
  # used for logout destination and when configuring SSO
  set {
    name  = "server.config.url"
    value = "https://argocd.${var.dns_zone_name}"
  }

  depends_on = [
    null_resource.argocd_cert_sync
  ]
}

# post-install config
resource "null_resource" "argocd_configure" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ARGOCD_ADMIN_PASSWORD              = var.argocd_admin_password
      ARGOCD_FQDN                        = var.argocd_fqdn
      HELM_CHART_REPO_DEPLOY_PRIVATE_KEY = var.helm_chart_repo_deploy_private_key
      KUBECONFIG                         = var.aks_config_path
      REPO_URL                           = "git@github.com:adamrushuk/charts-private.git"
    }

    command = <<-EOT
      chmod -R +x ./files/scripts
      timeout 10m ./files/scripts/argocd_config.sh
    EOT
  }

  depends_on = [
    local_sensitive_file.kubeconfig,
    helm_release.argocd
  ]
}

# create argo apps definition
# https://argoproj.github.io/argo-cd/operator-manual/cluster-bootstrapping/
resource "null_resource" "argocd_apps" {
  triggers = {
    argocd_app_yaml_contents = filemd5(var.argocd_apps_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = var.aks_config_path
    }
    command = <<-EOT
      kubectl apply -f ${var.argocd_apps_path}
    EOT
  }

  depends_on = [
    local_sensitive_file.kubeconfig,
    null_resource.argocd_configure
  ]
}
