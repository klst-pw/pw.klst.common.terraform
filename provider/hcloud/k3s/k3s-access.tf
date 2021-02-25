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

provider "kubernetes" {
  host                   = module.k3s.kubernetes.api_endpoint
  cluster_ca_certificate = module.k3s.kubernetes.cluster_ca_certificate
  client_certificate     = module.k3s.kubernetes.client_certificate
  client_key             = module.k3s.kubernetes.client_key
}

resource "kubernetes_service_account" "kube_bootstrap" {
  depends_on = [module.k3s.kubernetes_ready]

  metadata {
    name      = "kube-bootstrap"
    namespace = "kube-system"

    labels = {
      "app.kubernetes.io/name" : "kube-bootstrap",
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/part-of" : var.name,
      "app.kubernetes.io/managed-by" : "terraform",
    }
  }
}

# NOTE: currently, RBAC are only additive; no "deny" rules allowed.
#
# resource "kubernetes_role" "system_boostrap" {
#   depends_on = [module.k3s.kubernetes_ready]
#   for_each   = local.blacklisted_namespaced_resources

#   metadata {
#     name      = "system::bootstrap"
#     namespace = each.key

#     labels = {
#       "app.kubernetes.io/component" : "rbac"
#       "app.kubernetes.io/part-of" : var.name,
#       "app.kubernetes.io/managed-by" : "terraform",
#     }
#   }

#   dynamic "rule" {
#     for_each = each.value
#     content {
#       api_groups     = rule.value.api_groups
#       resources      = rule.value.resources
#       resource_names = rule.value.resource_names
#       verbs          = rule.value.verbs
#     }
#   }
# }

# resource "kubernetes_role_binding" "kube_boostrap" {
#   depends_on = [module.k3s.kubernetes_ready]
#   for_each   = local.blacklisted_namespaced_resources

#   metadata {
#     name      = "kube:bootstrap"
#     namespace = each.key

#     labels = {
#       "app.kubernetes.io/component" : "rbac"
#       "app.kubernetes.io/part-of" : var.name,
#       "app.kubernetes.io/managed-by" : "terraform",
#     }
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.kube_bootstrap.metadata[0].name
#     namespace = kubernetes_service_account.kube_bootstrap.metadata[0].namespace
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = "system::bootstrap"
#   }
# }

resource "kubernetes_cluster_role" "system_boostrap" {
  depends_on = [module.k3s.kubernetes_ready]

  metadata {
    name = "system::bootstrap"

    labels = {
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/part-of" : var.name,
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

  # NOTE: currently, RBAC are only additive; no "deny" rules allowed.
  #
  # dynamic "rule" {
  #   for_each = local.blacklisted_clustered_resources
  #   content {
  #     api_groups     = rule.value.api_groups
  #     resources      = rule.value.resources
  #     resource_names = rule.value.resource_names
  #     verbs          = rule.value.verbs
  #   }
  # }
}

resource "kubernetes_cluster_role_binding" "kube_boostrap" {
  depends_on = [module.k3s.kubernetes_ready, kubernetes_cluster_role.system_boostrap]

  metadata {
    name = "kube:bootstrap"

    labels = {
      "app.kubernetes.io/component" : "rbac"
      "app.kubernetes.io/part-of" : var.name,
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
  depends_on = [module.k3s.kubernetes_ready, kubernetes_cluster_role_binding.kube_boostrap]

  metadata {
    name      = kubernetes_service_account.kube_bootstrap.default_secret_name
    namespace = kubernetes_service_account.kube_bootstrap.metadata[0].namespace
  }
}
