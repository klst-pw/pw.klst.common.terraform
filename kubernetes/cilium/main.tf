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

resource "helm_release" "cilium" {
  name      = "cilium"
  namespace = "kube-system"

  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version

  set {
    name  = "operator.replicas"
    value = 1
  }

  set {
    name  = "prometheus.enabled"
    value = true
  }
  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = true
  }
  set {
    name  = "operator.prometheus.enabled"
    value = true
  }
  set {
    name  = "operator.prometheus.serviceMonitor.enabled"
    value = true
  }
  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,icmp,http}"
  }
  set {
    name  = "hubble.metrics.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "hubble.relay.enabled"
    value = var.enable_hubble
  }
  set {
    name  = "hubble.ui.enabled"
    value = var.enable_hubble
  }
}

resource "null_resource" "is_ready" {
  depends_on = [helm_release.cilium]
}