output "enabled" {
  description = "Whether this VyOS node configuration is active."
  value       = var.enabled
}

output "node_role" {
  description = "Role of this VyOS node (primary or secondary)."
  value       = var.node_role
}

output "vyos_url" {
  description = "VyOS HTTP API URL for this node."
  value       = var.vyos_url
}
