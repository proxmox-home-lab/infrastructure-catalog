locals {
  v = try(values, {})
}

unit "networking" {
  source = "git::https://github.com/proxmox-home-lab/infrastructure-catalog.git//units/proxmox-network?ref=main"
  path   = "networking"
  values = local.v
}
