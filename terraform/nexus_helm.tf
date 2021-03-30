# nexus helm chart

# https://www.terraform.io/docs/providers/kubernetes/r/namespace.html
resource "kubernetes_namespace" "nexus" {
  metadata {
    name = "nexus"
  }
  timeouts {
    delete = "15m"
  }

  depends_on = [module.aks]
}

# https://www.terraform.io/docs/provisioners/local-exec.html
resource "null_resource" "nexus_cert_sync" {
  triggers = {
    # always_run = "${timestamp()}"
    cert_sync_yaml_contents = filemd5(var.nexus_cert_sync_yaml_path)
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
      export KUBECONFIG=${var.aks_config_path}
      kubectl apply -f ${var.nexus_cert_sync_yaml_path}
    EOT
  }

  depends_on = [
    local_file.kubeconfig,
    helm_release.akv2k8s,
    kubernetes_namespace.nexus
  ]
}

# https://www.terraform.io/docs/providers/helm/r/release.html
resource "helm_release" "nexus" {
  chart      = "sonatype-nexus"
  name       = "nexus"
  namespace  = kubernetes_namespace.nexus.metadata[0].name
  repository = "https://adamrushuk.github.io/charts/"
  version    = var.nexus_chart_version
  timeout    = 600
  atomic     = true

  values = [file("helm/nexus_values.yaml")]

  set {
    name  = "image.tag"
    value = var.nexus_image_tag
  }

  set {
    name  = "nexus.baseDomain"
    value = var.nexus_base_domain
  }

  set {
    name  = "nexus.certEmail"
    value = var.nexus_cert_email
  }

  set {
    name  = "ingress.enabled"
    value = var.nexus_ingress_enabled
  }

  set {
    name  = "ingress.letsencryptEnvironment"
    value = var.nexus_letsencrypt_environment
  }

  set {
    name  = "ingress.tls.secretName"
    value = var.nexus_tls_secret_name
  }

  depends_on = [helm_release.nginx]
}
