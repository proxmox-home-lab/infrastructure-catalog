resource "proxmox_virtual_environment_vm" "vms" {
  count     = var.vm_count
  name      = "${var.name_prefix}-${count.index}"
  node_name = var.node
  on_boot   = true

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore
    file_id      = var.os_template
    interface    = "virtio0"
    size         = var.disk_size
    discard      = "on"
    iothread     = true
  }

  dynamic "network_device" {
    for_each = var.network_devices
    content {
      bridge  = network_device.value.bridge
      vlan_id = network_device.value.vlan_tag
      model   = network_device.value.model
    }
  }

  initialization {
    dynamic "ip_config" {
      for_each = var.ip_configs
      content {
        ipv4 {
          address = ip_config.value.address
          gateway = ip_config.value.gateway
        }
      }
    }

    user_account {
      keys = var.ssh_public_keys
    }
  }

  lifecycle {
    # Cloud-Init data is set once at creation; ignore drift after provisioning.
    ignore_changes = [initialization]
  }
}
