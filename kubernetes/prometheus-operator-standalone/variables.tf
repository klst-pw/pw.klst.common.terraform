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

variable "chart_version" {
  description = "Helm chart release version."
  type        = string
}

variable "operator_version" {
  description = "Operator release version."
  type        = string
}
