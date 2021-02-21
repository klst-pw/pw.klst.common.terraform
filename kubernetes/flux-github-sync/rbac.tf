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

resource "kubernetes_service_account" "flux_apps_sync" {
  metadata {
    name      = "flux-apps-sync"
    namespace = "flux-apps"

    labels = {
      "app.kubernetes.io/part" : "flux-apps-sync"
      "app.kubernetes.io/component" : "rbac"
    }
  }
}

resource "kubernetes_role" "flux_apps_sync" {
  metadata {
    name      = "flux:sync:${replace(var.repository, "/", ":")}"
    namespace = "flux-apps"

    labels = {
      "app.kubernetes.io/part" : "flux-apps-sync"
      "app.kubernetes.io/component" : "rbac"
    }
  }

  rule {
    api_groups = [
      "helm.toolkit.fluxcd.io",
      "kustomize.toolkit.fluxcd.io",
      "notification.toolkit.fluxcd.io",
      "source.toolkit.fluxcd.io",
    ]
    resources = ["*"]
    verbs     = ["*"]
  }
}

resource "kubernetes_role_binding" "flux_apps_sync" {
  metadata {
    name      = "flux:sync:${replace(var.repository, "/", ":")}"
    namespace = "flux-apps"

    labels = {
      "app.kubernetes.io/part" : "flux-apps-sync"
      "app.kubernetes.io/component" : "rbac"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.flux_apps_sync.metadata[0].name
    namespace = kubernetes_service_account.flux_apps_sync.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.flux_apps_sync.metadata[0].name
  }
}
