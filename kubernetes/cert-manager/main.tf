#                                       __
#                                     /\\ \
#                                   /\\ \\ \\
#                                   \// // //
#                                     \//_/
#
#                             K L S T - P r o j e c t
#                                Terraform  Module
#
# ------------------------------------------------------------------------------

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  namespace = "kube-system"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.certmanager_version

  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "prometheus.servicemonitor.enabled"
    value = var.enable_monitoring
  }
}

resource "null_resource" "is_ready" {
  depends_on = [helm_release.cert_manager]
}
