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

variable "name" {
  description = "Kubernetes project name (shoud be related to the Hetzner project)."
  type        = string
}

variable "sub_name" {
  description = "Kubernetes sub project name."
  type        = string
  default     = ""
}

variable "teams" {
  description = "List of teams allowed to manage/access to this project."
  type        = list(string)
  default     = []
}
