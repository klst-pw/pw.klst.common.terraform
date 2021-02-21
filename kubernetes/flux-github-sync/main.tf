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

resource "tls_private_key" "github_deploy_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "kubernetes_secret" "flux_sync" {
  metadata {
    name      = "flux-ssh-github"
    namespace = "flux-apps"
  }

  data = {
    identity       = tls_private_key.github_deploy_key.private_key_pem
    "identity.pub" = tls_private_key.github_deploy_key.public_key_pem
    known_hosts    = "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="
  }
}

resource "github_repository_deploy_key" "flux_sync" {
  title      = "flux-git-sync"
  repository = split("/", var.repository)[1]
  key        = tls_private_key.github_deploy_key.public_key_openssh
  read_only  = var.no_push
}

resource "kubectl_manifest" "flux_source_sync" {
  yaml_body = yamlencode({
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "GitRepository"
    metadata = {
      name      = "flux-github-sync-${replace(var.repository, "/", "-")}"
      namespace = "flux-apps"

      labels = {
        "app.kubernetes.io/part-of"   = "flux-apps-sync"
        "app.kubernetes.io/component" = "git-sync"
      }
    }

    spec = {
      interval = "1m0s"

      url    = "ssh://git@github.com/${var.repository}.git"
      ref    = { branch = var.repository_branch }
      ignore = <<EOGI
  # only include `/kubernetes`
  /*
  !/kubernetes
EOGI

      secretRef = { name = "flux-ssh-github" }

    }
  })
}

resource "kubectl_manifest" "flux_apps_sync" {
  yaml_body = yamlencode({
    apiVersion = "kustomize.toolkit.fluxcd.io/v1beta1"
    kind       = "Kustomization"
    metadata = {
      name      = "flux-apps-${replace(var.repository, "/", "-")}"
      namespace = "flux-apps"

      labels = {
        "app.kubernetes.io/part-of"   = "flux-apps-sync"
        "app.kubernetes.io/component" = "kube-sync"
      }
    }

    spec = {
      interval = "5m0s"

      sourceRef = {
        kind = "GitRepository"
        name = "flux-github-sync-${replace(var.repository, "/", "-")}"
      }
      path = "kubernetes/flux-apps" # this path is hard coded and must be the same everywhere

      serviceAccountName = kubernetes_service_account.flux_apps_sync.metadata[0].name
      prune              = true
      validation         = "server"
    }
  })
}

resource "null_resource" "is_ready" {
  depends_on = [
    kubectl_manifest.flux_source_sync,
    kubectl_manifest.flux_apps_sync
  ]
}
