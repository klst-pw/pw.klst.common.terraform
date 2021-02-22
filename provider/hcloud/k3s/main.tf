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

locals {
  project_name     = var.sub_name == "" ? var.name : var.sub_name + "." + var.name
  default_ssh_keys = ["admin", "iaas"]
  allowed_ssh_keys = distinct(flatten([for team in data.hcloud_ssh_keys.allowed_teams : try(team.ssh_keys.*.name, [])]))

  kubernetes_labels = {
    "provider.klst.pw/name"    = "hetzner"
    "provider.klst.pw/tenant"  = var.name
    "cloud.klst.pw/project"    = local.project_name
    "cloud.klst.pw/type"       = "kubernetes"
    "k3s.klst.pw/cluster-name" = local.project_name
    "team.klst.pw/allowed"     = join("_", var.teams)
  }
}

data "hcloud_image" "os" {
  name = var.image
}
data "hcloud_locations" "availability_zones" {}
data "hcloud_ssh_keys" "allowed_teams" {
  for_each      = toset(concat(local.default_ssh_keys, var.teams))
  with_selector = "team.klst.pw/${each.value}"
}
