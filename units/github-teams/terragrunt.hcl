include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  defaults = {
    version = "main"
    name    = "default-teams"
  }

  values = merge(
    local.defaults,
    try(values, {})
  )
}

terraform {
  source = "github.com/proxmox-home-lab/infrastructure-catalog.git//modules/github-teams?ref=${local.values.version}"
}

inputs = local.values