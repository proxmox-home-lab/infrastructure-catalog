mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_network_linux_bridge" {
    defaults = {
      name = "vmbr0"
    }
  }

  mock_resource "proxmox_virtual_environment_network_linux_vlan" {
    defaults = {
      name = "vmbr1.10"
    }
  }
}

variables {
  node = "pve"
}

run "empty_config_creates_nothing" {
  command = plan

  assert {
    condition     = length(proxmox_virtual_environment_network_linux_bridge.bridges) == 0
    error_message = "No bridges should be created with empty config"
  }

  assert {
    condition     = length(proxmox_virtual_environment_network_linux_vlan.vlans) == 0
    error_message = "No VLANs should be created with empty config"
  }
}

run "create_bridges" {
  command = plan

  variables {
    bridges = {
      vmbr0 = { comment = "WAN uplink" }
      vmbr1 = { comment = "Internal trunk", vlan_aware = true }
    }
  }

  assert {
    condition     = length(proxmox_virtual_environment_network_linux_bridge.bridges) == 2
    error_message = "Expected 2 bridges"
  }
}

run "create_vlans" {
  command = plan

  variables {
    vlans = {
      vlan10 = { vlan_id = 10, interface = "vmbr1", comment = "RKE2" }
      vlan20 = { vlan_id = 20, interface = "vmbr1", comment = "Reserved" }
    }
  }

  assert {
    condition     = length(proxmox_virtual_environment_network_linux_vlan.vlans) == 2
    error_message = "Expected 2 VLANs"
  }
}
