include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repository_url = "github.com/proxmox-home-lab/infrastructure-catalog.git"
  caller_values  = try(values, {})

  defaults = {
    version      = "main"
    remote_user  = "ubuntu"
    extra_vars   = {}
    triggers     = {}
  }

  merged = merge(local.defaults, local.caller_values)
}

# inventory_hosts is populated by the consuming stack via a dependency block
# on the proxmox-vm unit. See stacks/haproxy/terragrunt.stack.hcl for the pattern.

terraform {
  source = "${local.repository_url}//modules/ansible-run?ref=${local.merged.version}"
}

inputs = local.merged
