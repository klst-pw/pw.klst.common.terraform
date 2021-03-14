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

resource "kubernetes_service_account" "kube_bootstrap" {
  metadata {
    name      = "kube-bootstrap"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" : "kube-bootstrap",
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/managed-by" : "terraform",
    }
  }
}

resource "kubernetes_cluster_role" "system_boostrap" {
  metadata {
    name = "system::bootstrap"

    labels = {
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/managed-by" : "terraform",
    }
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    non_resource_urls = ["*"]
    verbs             = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "kube_boostrap" {
  depends_on = [kubernetes_cluster_role.system_boostrap]

  metadata {
    name = "kube:bootstrap"

    labels = {
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/managed-by" : "terraform",
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_bootstrap.metadata[0].name
    namespace = kubernetes_service_account.kube_bootstrap.metadata[0].namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system::bootstrap"
  }
}

data "kubernetes_secret" "kube_bootstrap_token" {
  depends_on = [kubernetes_cluster_role_binding.kube_boostrap]

  metadata {
    name      = kubernetes_service_account.kube_bootstrap.default_secret_name
    namespace = kubernetes_service_account.kube_bootstrap.metadata[0].namespace
  }
}
