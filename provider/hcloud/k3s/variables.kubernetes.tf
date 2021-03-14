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

variable "k3s_version" {
  description = "Specify the k3s version. You can choose from the following release channels or pin the version directly."
  type        = string
  default     = "latest"
}

variable "drain_timeout" {
  description = "The length of time to wait before giving up the node draining. 30s by default."
  type        = string
  default     = "30s"
}

variable "k3s_args" {
  description = "Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type        = list(string)
  default     = []
}

variable "control_planes_as_bastion" {
  description = "Use control-plane nodes as bastion."
  type        = bool
  default     = false
}

variable "control_planes" {
  description = "Control-plane nodes definitions."
  type = object({
    count         = number
    instance_type = string

    k3s_args    = optional(list(string))
    annotations = optional(map(string))
    labels      = optional(map(string))
    taints      = optional(map(string))

    security_group = optional(object({
      inbound_rules = optional(list(object({
        protocol    = optional(string)
        cidr_blocks = list(string)
        port_range  = string
      })))
      outbound_rules = optional(list(object({
        protocol    = optional(string)
        cidr_blocks = list(string)
        port_range  = string
      })))
    }))
  })

  validation {
    condition     = var.control_planes.count > 0
    error_message = "At least one control-plane node must be provided."
  }
  validation {
    condition     = var.control_planes.count % 2 == 1
    error_message = "Control-planes must have an odd number of nodes."
  }
  validation {
    condition     = contains(["cx11", "cx11-ceph", "cx21", "cx21-ceph", "cx31", "cx31-ceph", "cx41", "cx41-ceph", "cx51", "cx51-ceph", "ccx11", "ccx21", "ccx31", "ccx41", "ccx51", "cpx11", "cpx21", "cpx31", "cpx41", "cpx51"], var.control_planes.instance_type)
    error_message = "Field control_planes.type is required and must be valid. List of all type available with `hcloud server-type list`."
  }
}

variable "node_pools" {
  description = "Node pools definitions."
  type = map(object({
    count         = number
    instance_type = string

    k3s_args    = optional(list(string))
    annotations = optional(map(string))
    labels      = optional(map(string))
    taints      = optional(map(string))

    security_group = optional(object({
      inbound_rules = optional(list(object({
        protocol    = optional(string)
        cidr_blocks = list(string)
        port_range  = string
      })))
      outbound_rules = optional(list(object({
        protocol    = optional(string)
        cidr_blocks = list(string)
        port_range  = string
      })))
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for _, pool in var.node_pools : contains(["cx11", "cx11-ceph", "cx21", "cx21-ceph", "cx31", "cx31-ceph", "cx41", "cx41-ceph", "cx51", "cx51-ceph", "ccx11", "ccx21", "ccx31", "ccx41", "ccx51", "cpx11", "cpx21", "cpx31", "cpx41", "cpx51"], pool.instance_type)])
    error_message = "Field node_pools.*.type is required and must be valid. List of all type available with `hcloud server-type list`."
  }
}
