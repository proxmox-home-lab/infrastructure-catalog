output "playbook_path" {
  description = "Path of the Ansible playbook that was executed."
  value       = var.playbook_path
}

output "inventory_hosts" {
  description = "List of hosts the playbook was executed against."
  value       = var.inventory_hosts
}
