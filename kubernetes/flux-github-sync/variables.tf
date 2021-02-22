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

variable "repository" {
  description = "Github repository name."
  type        = string

  validation {
    condition     = can(regex("^[\\w\\d.-]+/[\\w\\d.-]+", var.repository))
    error_message = "The git repository must be a valid repository name of the form <org>/<name>."
  }
}

variable "repository_branch" {
  description = "Repository branch name to be synced."
  type        = string
  default     = "main"
}

variable "no_push" {
  description = "Flux should be update the repository?"
  type        = bool
  default     = false
}
