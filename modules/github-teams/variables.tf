variable "name" {
  description = "The name of the team"
  type        = string
}

variable "description" {
  description = "A description of the team"
  type        = string
  default     = null
}

variable "privacy" {
  description = "The level of privacy for the team. Must be one of secret or closed"
  type        = string
  default     = "closed"
  validation {
    condition     = contains(["secret", "closed"], var.privacy)
    error_message = "Privacy must be either 'secret' or 'closed'."
  }
}

variable "parent_team_id" {
  description = "The ID of the parent team, if this is a nested team"
  type        = number
  default     = null
}

variable "members" {
  description = "Map of team members with their roles (maintainer or member)"
  type        = map(string)
  default     = {}
  validation {
    condition = alltrue([
      for role in values(var.members) : contains(["maintainer", "member"], role)
    ])
    error_message = "Member roles must be either 'maintainer' or 'member'."
  }
}
