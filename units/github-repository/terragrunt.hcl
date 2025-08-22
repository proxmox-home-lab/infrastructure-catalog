include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  defaults = {
    version      = "main"
    name         = "default-repo"
    auto_init    = true
    has_issues   = true
    has_projects = true
  }

  values = merge(
    local.defaults,
    try(values, {})
  )
}

terraform {
  source = "github.com/proxmox-home-lab/infrastructure-catalog.git//modules/github-repository?ref=${local.values.version}"
}

inputs = local.values