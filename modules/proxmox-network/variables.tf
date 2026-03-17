variable "node" {
  description = "Proxmox node name where bridges and VLANs will be configured."
  type        = string
}

variable "bridges" {
  description = "Map of Linux bridges to create. Key is the bridge name (e.g. vmbr1)."
  type = map(object({
    comment    = optional(string, "")
    vlan_aware = optional(bool, false)
  }))
  default = {}
}

variable "vlans" {
  description = "Map of VLAN interfaces to create. Key is a logical name."
  type = map(object({
    vlan_id   = number
    interface = string
    comment   = optional(string, "")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.vlans : v.vlan_id >= 1 && v.vlan_id <= 4094
    ])
    error_message = "VLAN IDs must be between 1 and 4094."
  }
}
