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

variable "cilium_version" {
  description = "Cilium release version."
  type        = string
}

variable "enable_hubble" {
  description = "Enable Cilium Hubble."
  type        = bool
  default     = false
}