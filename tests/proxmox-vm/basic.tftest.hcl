mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_vm" {
    defaults = {
      id              = "100"
      ipv4_addresses  = [[], ["192.168.1.10"]]
    }
  }
}

variables {
  node        = "pve"
  name_prefix = "test"
  os_template = "local:iso/ubuntu-24.04-cloud.img"
  network_devices = [
    { bridge = "vmbr0", vlan_tag = null, model = "virtio" }
  ]
  ip_configs = [
    { address = "192.168.1.10/24", gateway = "192.168.1.1" }
  ]
  ssh_public_keys = ["ssh-ed25519 AAAA test"]
}

run "single_vm_default" {
  command = plan

  assert {
    condition     = length(proxmox_virtual_environment_vm.vms) == 1
    error_message = "Expected 1 VM with default vm_count=1"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms[0].name == "test-0"
    error_message = "Expected VM name 'test-0'"
  }
}

run "cluster_three_vms" {
  command = plan

  variables {
    vm_count = 3
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.vms) == 3
    error_message = "Expected 3 VMs for vm_count=3"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms[2].name == "test-2"
    error_message = "Expected third VM name 'test-2'"
  }
}

run "zero_vms_creates_nothing" {
  command = plan

  variables {
    vm_count = 0
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.vms) == 0
    error_message = "vm_count=0 should create no VMs"
  }
}

run "custom_resources" {
  command = plan

  variables {
    cores     = 4
    memory    = 4096
    disk_size = 40
    datastore = "ceph-pool"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.vms[0].memory[0].dedicated == 4096
    error_message = "Expected dedicated memory 4096"
  }
}
