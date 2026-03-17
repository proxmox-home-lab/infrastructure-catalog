locals {
  # All resources use count = var.enabled ? 1 : 0 so secondary nodes in a
  # single-node cluster are a clean no-op without removing the unit block.
  enabled = var.enabled ? 1 : 0
}

resource "vyos_config_block_tree" "interfaces" {
  count = local.enabled

  path = "interfaces ethernet"

  configs = {
    for iface, cfg in var.interfaces :
    iface => merge(
      cfg.description != "" ? { description = cfg.description } : {},
      cfg.address != null ? { address = cfg.address } : {}
    )
  }
}

resource "vyos_config_block_tree" "vlans" {
  count = local.enabled

  path = "interfaces ethernet"

  configs = {
    for vlan_iface, cfg in var.vlans :
    vlan_iface => merge(
      cfg.description != "" ? { description = cfg.description } : {},
      cfg.address != null ? { address = cfg.address } : {}
    )
  }
}

resource "vyos_config_block_tree" "nat" {
  count = local.enabled > 0 && length(var.nat_rules) > 0 ? 1 : 0

  path = "nat"

  configs = {
    for idx, rule in var.nat_rules :
    "rule ${(idx + 1) * 10}" => merge(
      { type = rule.type },
      rule.outbound_interface != null ? { "outbound-interface" = rule.outbound_interface } : {},
      rule.port != null ? { "destination port" = tostring(rule.port) } : {},
      rule.to_address != null ? { "translation address" = rule.to_address } : {}
    )
  }
}

resource "vyos_config_block_tree" "firewall" {
  count = local.enabled > 0 && length(var.firewall_zones) > 0 ? 1 : 0

  path = "firewall"

  configs = {
    for zone, cfg in var.firewall_zones :
    "zone-policy zone ${zone}" => merge(
      { "default-action" = cfg.default_action },
      { interface = cfg.interfaces }
    )
  }
}

resource "vyos_config_block_tree" "vrrp" {
  count = local.enabled > 0 && var.vrrp_config != null ? 1 : 0

  path = "high-availability vrrp group primary"

  configs = {
    "vrid"             = tostring(var.vrrp_config.vrid)
    "interface"        = var.vrrp_config.interface
    "virtual-address"  = var.vrrp_config.virtual_address
    "priority"         = tostring(var.vrrp_config.priority)
    "preempt"          = var.vrrp_config.preempt ? "enable" : "disable"
  }
}
