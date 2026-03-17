include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repository_url = "github.com/proxmox-home-lab/infrastructure-catalog.git"
  caller_values  = try(values, {})

  defaults = {
    version   = "main"
    vm_count  = 1
    cores     = 2
    memory    = 2048
    disk_size = 20
    datastore = "local-lvm"
  }

  merged = merge(local.defaults, local.caller_values)
}

terraform {
  source = "${local.repository_url}//modules/proxmox-vm?ref=${local.merged.version}"
}

inputs = local.merged
