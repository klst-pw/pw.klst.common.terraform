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

resource "hcloud_network" "main" {
  name     = local.project_name
  ip_range = var.network
  labels = {
    "cloud.klst.pw/project" = local.project_name
    "cloud.klst.pw/type"    = "kubernetes"
  }
}

resource "hcloud_network_subnet" "default" {
  network_zone = "eu-central"
  network_id   = hcloud_network.main.id
  type         = "server"
  ip_range     = var.network
}
