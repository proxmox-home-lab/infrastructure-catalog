locals {
  v        = try(values, {})
  vm_count = try(local.v.vm_count, 1)
}

# Provision N HAProxy VMs
unit "haproxy-vms" {
  source = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/proxmox-vm?ref=main"
  path   = "haproxy-vms"
  values = {
    version         = try(local.v.version, "main")
    vm_count        = local.vm_count
    name_prefix     = "haproxy"
    node            = local.v.node
    cores           = try(local.v.cores, 2)
    memory          = try(local.v.memory, 2048)
    disk_size       = try(local.v.disk_size, 20)
    os_template     = local.v.os_template
    network_devices = local.v.network_devices
    ip_configs      = local.v.ip_configs
    ssh_public_keys = try(local.v.ssh_public_keys, [])
  }
}

# Configure HAProxy on all provisioned VMs via Ansible.
# The unit's terragrunt.hcl uses a dependency block on ../haproxy-vms to
# read ip_addresses and pass them as inventory_hosts automatically.
unit "haproxy-config" {
  source     = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/ansible-run?ref=main"
  path       = "haproxy-config"
  depends_on = [unit.haproxy-vms]
  values = {
    version              = try(local.v.version, "main")
    playbook_path        = local.v.ansible_playbook
    ssh_private_key_path = local.v.ssh_private_key_path
    remote_user          = try(local.v.remote_user, "ubuntu")
    extra_vars           = try(local.v.haproxy_vars, {})
    # inventory_hosts is injected by the unit via dependency on ../haproxy-vms
  }
}
