variable "playbook_path" {
  description = "Path to the Ansible playbook file relative to the repo root."
  type        = string
}

variable "inventory_hosts" {
  description = "List of target host IP addresses or hostnames. 1 = standalone, N = cluster."
  type        = list(string)

  validation {
    condition     = length(var.inventory_hosts) > 0
    error_message = "inventory_hosts must contain at least one host."
  }
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file used to connect to inventory hosts."
  type        = string
  sensitive   = true
}

variable "remote_user" {
  description = "SSH user to connect as on target hosts."
  type        = string
  default     = "ubuntu"
}

variable "extra_vars" {
  description = "Extra variables passed to ansible-playbook via --extra-vars."
  type        = map(string)
  default     = {}
}

variable "triggers" {
  description = "Map of trigger values. Change any value to force re-execution of the playbook."
  type        = map(string)
  default     = {}
}
