include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repository_url = "github.com/proxmox-home-lab/infrastructure-catalog.git"
  caller_values  = try(values, {})

  defaults = {
    version = "main"
    bridges = {}
    vlans   = {}
  }

  merged = merge(local.defaults, local.caller_values)
}

terraform {
  source = "${local.repository_url}//modules/proxmox-network?ref=${local.merged.version}"
}

inputs = local.merged
