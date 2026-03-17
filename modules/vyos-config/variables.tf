variable "enabled" {
  description = "Set to false to skip all resources (no-op). Used for cluster secondary nodes that are conditionally active."
  type        = bool
  default     = true
}

variable "node_role" {
  description = "Role of this VyOS node. 'primary' or 'secondary'."
  type        = string
  default     = "primary"

  validation {
    condition     = contains(["primary", "secondary"], var.node_role)
    error_message = "node_role must be 'primary' or 'secondary'."
  }
}

variable "vyos_url" {
  description = "VyOS HTTP API URL (e.g. https://10.10.0.1)."
  type        = string
}

variable "vyos_api_key" {
  description = "VyOS HTTP API key."
  type        = string
  sensitive   = true
}

variable "interfaces" {
  description = "Map of interface name to configuration. Key is the interface name (e.g. eth0)."
  type = map(object({
    address     = optional(string, null)
    description = optional(string, "")
  }))
  default = {}
}

variable "vlans" {
  description = "Map of VLAN sub-interface name to configuration (e.g. 'eth1.10')."
  type = map(object({
    address     = optional(string, null)
    description = optional(string, "")
  }))
  default = {}
}

variable "nat_rules" {
  description = "List of NAT rules to configure."
  type = list(object({
    type               = string
    outbound_interface = optional(string, null)
    port               = optional(number, null)
    to_address         = optional(string, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for r in var.nat_rules : contains(["masquerade", "dnat", "snat"], r.type)
    ])
    error_message = "NAT rule type must be 'masquerade', 'dnat', or 'snat'."
  }
}

variable "firewall_zones" {
  description = "Map of firewall zone name to configuration."
  type = map(object({
    default_action = string
    interfaces     = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.firewall_zones : contains(["accept", "drop", "reject"], v.default_action)
    ])
    error_message = "Firewall zone default_action must be 'accept', 'drop', or 'reject'."
  }
}

variable "vrrp_config" {
  description = "VRRP configuration for HA. Set to null for standalone (non-HA) nodes."
  type = object({
    vrid              = number
    interface         = string
    virtual_address   = string
    priority          = optional(number, 100)
    preempt           = optional(bool, true)
    authentication    = optional(string, null)
    authentication_pw = optional(string, null)
  })
  default   = null
  sensitive = false
}
