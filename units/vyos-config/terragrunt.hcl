include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repository_url = "github.com/proxmox-home-lab/infrastructure-catalog.git"
  caller_values  = try(values, {})

  defaults = {
    version        = "main"
    enabled        = true
    node_role      = "primary"
    interfaces     = {}
    vlans          = {}
    nat_rules      = []
    firewall_zones = {}
    vrrp_config    = null
  }

  merged = merge(local.defaults, local.caller_values)
}

# Dynamic IP for this node is injected by the consuming stack via a
# dependency block on the proxmox-vm unit. The dependency sets vyos_url
# using the ip_addresses output indexed by node_index.
# See stacks/vyos/terragrunt.stack.hcl for the full pattern.

terraform {
  source = "${local.repository_url}//modules/vyos-config?ref=${local.merged.version}"
}

inputs = local.merged
