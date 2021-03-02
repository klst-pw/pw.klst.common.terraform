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

variable "certmanager_version" {
  description = "Cert-manager release version."
  type        = string
}

variable "enable_monitoring" {
  description = "Enable service monitors (Prometheus required)."
  type        = bool
  default     = true
}
