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

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
    labels = {
      "app.kubernetes.io/instance" : "flux-system"
    }
  }
}

resource "kubernetes_namespace" "flux_apps" {
  metadata {
    name = "flux-apps"
    labels = {
      "app.kubernetes.io/instance" : "flux-apps"
    }
  }
}

resource "kubectl_manifest" "flux_system_install" {
  depends_on = [kubernetes_namespace.flux_system]
  for_each = {
    for v in local.flux_manifests :
    lower(join("/", compact([v.apiVersion, v.kind, lookup(v.metadata, "namespace", ""), v.metadata.name]))) => yamlencode(v)
  }

  yaml_body = each.value
}

resource "kubectl_manifest" "flux_system_monitor" {
  depends_on = [kubernetes_namespace.flux_system]

  yaml_body = <<EOY
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: flux-system
  namespace: flux-system
  labels:
    app.kubernetes.io/component: monitor
    app.kubernetes.io/part-of: flux-system
spec:
  jobLabel: flux
  podMetricsEndpoints:
  - interval: 30s
    path: /metrics
    scrapeTimeout: 10s
    port: http-prom

  namespaceSelector:
    matchNames:
    - flux-system
  selector:
    matchExpressions:
    - key: app
      operator: In
      values:
      - helm-controller
      - kustomize-controller
      - notification-controller
      - source-controller
EOY
}

resource "null_resource" "is_ready" {
  depends_on = [kubectl_manifest.flux_system_install]
}
