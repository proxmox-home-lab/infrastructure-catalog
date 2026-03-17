output "bridge_names" {
  description = "Map of logical name to bridge name for created bridges."
  value       = { for k, v in proxmox_virtual_environment_network_linux_bridge.bridges : k => v.name }
}

output "vlan_names" {
  description = "Map of logical name to VLAN interface name for created VLANs."
  value       = { for k, v in proxmox_virtual_environment_network_linux_vlan.vlans : k => v.name }
}
