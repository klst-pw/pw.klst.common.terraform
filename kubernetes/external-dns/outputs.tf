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

output "is_ready" {
  description = "Dependency endpoint to synchronize provisioning."
  value       = null_resource.is_ready
}
