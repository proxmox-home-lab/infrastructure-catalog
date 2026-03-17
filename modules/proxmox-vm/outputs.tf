output "vm_ids" {
  description = "List of Proxmox VM IDs."
  value       = [for vm in proxmox_virtual_environment_vm.vms : vm.id]
}

output "ip_addresses" {
  description = "List of VM IP addresses (first NIC, first address)."
  value       = [for vm in proxmox_virtual_environment_vm.vms : try(vm.ipv4_addresses[1][0], "")]
}

output "hostnames" {
  description = "List of VM hostnames."
  value       = [for vm in proxmox_virtual_environment_vm.vms : vm.name]
}
