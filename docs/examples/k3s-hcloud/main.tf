#                                       __
#                                     /\\ \
#                                   /\\ \\ \\
#                                   \// // //
#                                     \//_/
#
#                             K L S T - P r o j e c t
#                                Terraform Example
#
# ------------------------------------------------------------------------------

module "kubernetes" {
  source = "../../../provider/hcloud/k3s"

  name = "kubernetes.example.com"

  image       = "ubuntu-20.04"
  k3s_version = "latest"
  k3s_args    = []

  control_planes_as_bastion = true
  control_planes = {
    count         = 1
    instance_type = "cx11"
    security_group = {
      inbound_rules = [
        { "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "80" },  // Allow HTTP port (ingress)
        { "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "443" }, // Allow HTTPS port (ingress)

        { "cidr_blocks" : ["172.16.1.0/24"], "port_range" : "8472" }, // Allow Flannel VXLAN for cluster-side nodes
      ]
    }
  }

  node_pools = {
    default = {
      count         = 2
      instance_type = "cx11"
      security_group = {
        inbound_rules = [
          { "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "80" },  // Allow HTTP port (ingress)
          { "cidr_blocks" : ["0.0.0.0/0", "::/0"], "port_range" : "443" }, // Allow HTTPS port (ingress)
        ]
      }
    }
  }
}
