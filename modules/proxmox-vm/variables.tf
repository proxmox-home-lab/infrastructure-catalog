variable "vm_count" {
  description = "Number of VMs to create. 1 = standalone, 2+ = cluster."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 0
    error_message = "vm_count must be >= 0."
  }
}

variable "name_prefix" {
  description = "Name prefix for VMs. VMs are named <prefix>-0, <prefix>-1, ..."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "name_prefix must be lowercase alphanumeric with hyphens only."
  }
}

variable "node" {
  description = "Proxmox node name where VMs will be created."
  type        = string
}

variable "cores" {
  description = "Number of CPU cores per VM."
  type        = number
  default     = 2

  validation {
    condition     = var.cores >= 1
    error_message = "cores must be >= 1."
  }
}

variable "memory" {
  description = "Memory in MB per VM."
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 512
    error_message = "memory must be >= 512 MB."
  }
}

variable "disk_size" {
  description = "Boot disk size in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.disk_size >= 5
    error_message = "disk_size must be >= 5 GB."
  }
}

variable "datastore" {
  description = "Proxmox datastore for VM disks."
  type        = string
  default     = "local-lvm"
}

variable "os_template" {
  description = "Proxmox content reference for the VM template (e.g. local:iso/ubuntu-24.04-cloud.img)."
  type        = string
}

variable "network_devices" {
  description = "List of network interfaces. One entry per NIC."
  type = list(object({
    bridge   = string
    vlan_tag = optional(number, null)
    model    = optional(string, "virtio")
  }))
}

variable "ip_configs" {
  description = "Cloud-Init IP configuration per NIC. Use 'dhcp' for DHCP. Must match length of network_devices."
  type = list(object({
    address = string
    gateway = optional(string, null)
  }))

  validation {
    condition     = length(var.ip_configs) == length(var.network_devices)
    error_message = "ip_configs must have the same number of entries as network_devices."
  }
}

variable "ssh_public_keys" {
  description = "List of SSH public keys for the default Cloud-Init user."
  type        = list(string)
  default     = []
  sensitive   = true
}
