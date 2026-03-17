resource "proxmox_virtual_environment_network_linux_bridge" "bridges" {
  for_each = var.bridges

  node_name  = var.node
  name       = each.key
  comment    = each.value.comment
  vlan_aware = each.value.vlan_aware
}

resource "proxmox_virtual_environment_network_linux_vlan" "vlans" {
  for_each = var.vlans

  node_name = var.node
  name      = "${each.value.interface}.${each.value.vlan_id}"
  comment   = each.value.comment
}
