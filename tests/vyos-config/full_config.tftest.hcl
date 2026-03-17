mock_provider "vyos" {
  mock_resource "vyos_config_block_tree" {
    defaults = {}
  }
}

variables {
  vyos_url     = "https://10.10.0.1"
  vyos_api_key = "test-api-key"
}

run "disabled_node_creates_nothing" {
  command = plan

  variables {
    enabled = false
    interfaces = {
      eth0 = { address = "dhcp", description = "WAN" }
    }
  }

  assert {
    condition     = length(vyos_config_block_tree.interfaces) == 0
    error_message = "disabled node should create no interface resources"
  }

  assert {
    condition     = length(vyos_config_block_tree.vlans) == 0
    error_message = "disabled node should create no VLAN resources"
  }
}

run "primary_node_full_config" {
  command = plan

  variables {
    enabled   = true
    node_role = "primary"
    interfaces = {
      eth0 = { address = "dhcp", description = "WAN" }
      eth1 = { description = "Internal trunk" }
    }
    vlans = {
      "eth1.10" = { address = "10.10.1.1/24", description = "vlan01" }
    }
    nat_rules = [
      { type = "masquerade", outbound_interface = "eth0" }
    ]
    firewall_zones = {
      WAN  = { default_action = "drop", interfaces = ["eth0"] }
      mgmt = { default_action = "accept", interfaces = ["eth1.0"] }
    }
  }

  assert {
    condition     = length(vyos_config_block_tree.interfaces) == 1
    error_message = "Expected interface config resource"
  }

  assert {
    condition     = length(vyos_config_block_tree.nat) == 1
    error_message = "Expected NAT config resource"
  }

  assert {
    condition     = length(vyos_config_block_tree.firewall) == 1
    error_message = "Expected firewall config resource"
  }
}

run "ha_node_with_vrrp" {
  command = plan

  variables {
    enabled   = true
    node_role = "primary"
    vrrp_config = {
      vrid            = 10
      interface       = "eth1"
      virtual_address = "10.10.0.1/24"
      priority        = 150
    }
  }

  assert {
    condition     = length(vyos_config_block_tree.vrrp) == 1
    error_message = "Expected VRRP config resource when vrrp_config is set"
  }
}

run "no_vrrp_for_standalone" {
  command = plan

  variables {
    enabled     = true
    vrrp_config = null
  }

  assert {
    condition     = length(vyos_config_block_tree.vrrp) == 0
    error_message = "Expected no VRRP resource for standalone node"
  }
}
