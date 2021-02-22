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

resource "helm_release" "prometheus_operator" {
  name      = "prometheus-operator"
  namespace = "kube-observability"

  repository = "https://kubernetes-charts.banzaicloud.com"
  chart      = "prometheus-operator-standalone"
  version    = var.chart_version

  values = [
    yamlencode({
      prometheusOperator = {
        podAnnotations = { "scheduler.alpha.kubernetes.io/critical-pod" : "" }
        tolerations = [
          { "effect" : "NoSchedule", "key" : "node.cloudprovider.kubernetes.io/uninitialized", "value" : "true" },
          { "key" : "CriticalAddonsOnly", "operator" : "Exists" },
          { "effect" : "NoSchedule", "key" : "node-role.kubernetes.io/master", "operator" : "Equal" },
          { "effect" : "NoSchedule", "key" : "node.kubernetes.io/not-ready", "operator" : "Equal" },
          { "effect" : "NoSchedule", "key" : "node.kubernetes.io/network-unavailable", "operator" : "Equal" }
        ]
      }
    })
  ]

  set {
    name  = "prometheusOperator.image.version"
    value = var.operator_version
  }

  set {
    name  = "fullnameOverride"
    value = "prometheus-operator-standalone"
  }
  set {
    name  = "prometheusOperator.serviceMonitor.selfMonitor"
    value = false
  }

  create_namespace = true
  wait             = false # no lock
}

resource "null_resource" "is_ready" {
  depends_on = [helm_release.prometheus_operator]
}