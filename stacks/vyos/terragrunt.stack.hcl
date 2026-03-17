locals {
  v          = try(values, {})
  vm_count   = try(local.v.vm_count, 1)
  ha_enabled = local.vm_count > 1
}

# Provision N VyOS VMs (1 = standalone, 2+ = HA cluster)
unit "vyos-vms" {
  source = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/proxmox-vm?ref=main"
  path   = "vyos-vms"
  values = {
    version         = try(local.v.version, "main")
    vm_count        = local.vm_count
    name_prefix     = "vyos"
    node            = local.v.node
    cores           = try(local.v.cores, 2)
    memory          = try(local.v.memory, 1024)
    disk_size       = try(local.v.disk_size, 20)
    os_template     = local.v.os_template
    network_devices = local.v.network_devices
    ip_configs      = local.v.ip_configs
    ssh_public_keys = try(local.v.ssh_public_keys, [])
  }
}

# Primary VyOS node — always active
# The unit's terragrunt.hcl uses a dependency block on ../vyos-vms to read
# the VM's IP address and set vyos_url dynamically.
unit "vyos-node-0" {
  source     = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/vyos-config?ref=main"
  path       = "vyos-node-0"
  depends_on = [unit.vyos-vms]
  values = merge(try(local.v.vyos_config, {}), {
    version    = try(local.v.version, "main")
    enabled    = true
    node_role  = "primary"
    node_index = 0
  })
}

# Secondary VyOS node — active only when vm_count >= 2.
# All resources inside vyos-config use count = var.enabled ? 1 : 0,
# so this unit is a clean no-op when ha_enabled = false.
unit "vyos-node-1" {
  source     = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/vyos-config?ref=main"
  path       = "vyos-node-1"
  depends_on = [unit.vyos-vms]
  values = merge(try(local.v.vyos_config, {}), {
    version     = try(local.v.version, "main")
    enabled     = local.ha_enabled
    node_role   = "secondary"
    node_index  = 1
    vrrp_config = local.ha_enabled ? try(local.v.vrrp_config, null) : null
  })
}
