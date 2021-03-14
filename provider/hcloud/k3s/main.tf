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

  k3s_firewall_rules = {
    control_planes = [
      { "protocol" : "TCP", "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "22" },   // Allow SSH port for everyone
      { "protocol" : "TCP", "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "6443" }, // Allow Kubernetes API port for everyone
      { "protocol" : "ICMP", "cidr_blocks" : [var.network], "port_range" : null },          // Allow ping between nodes
      { "protocol" : "TCP", "cidr_blocks" : [var.network], "port_range" : "2379-2380" },    // Allow ETCD for all nodes in the network
      { "protocol" : "TCP", "cidr_blocks" : [var.network], "port_range" : "10250" },        // Allow Kubelet metric for all nodes in the network
    ]
    nodes = [
      { "protocol" : "ICMP", "cidr_blocks" : [var.network], "port_range" : null },                                                        // Allow ping between nodes
      { "protocol" : "TCP", "cidr_blocks" : var.control_planes_as_bastion ? [var.network] : ["0.0.0.0/0", "::/0"], "port_range" : "22" }, // Allow SSH port for everyone
      { "protocol" : "TCP", "cidr_blocks" : [var.network], "port_range" : "10250" },                                                      // Allow Kubelet metric for all nodes in the network
    ]
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
