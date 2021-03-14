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
# NOTE: the RBAC resources are managed on a submodule to easily disable it 
#       during destroying process;
#       In fact, because the `k3s` module is disabled when all resources are
#       destroyed, we didn't need to manage theses RBAC at all... so we will
#       disable them too.

provider "kubernetes" {
  host                   = try(module.k3s[0].kubernetes.api_endpoint, null)
  cluster_ca_certificate = try(module.k3s[0].kubernetes.cluster_ca_certificate, null)
  client_certificate     = try(module.k3s[0].kubernetes.client_certificate, null)
  client_key             = try(module.k3s[0].kubernetes.client_key, null)
}

module "bootstrap_rbac" {
  // NOTE: enable this module ONLY if the module `k3s` is instancied
  count      = length(local.control_plane_nodes) == 0 ? 0 : 1
  depends_on = [module.k3s[0].kubernetes_ready]

  source = "./bootstrap_rbac"
}
