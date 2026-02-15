include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path   = find_in_parent_folders("common.hcl")
  expose = true
}

locals {
  repository_url = try(include.common.locals.repository_url, null)
  defaults = {
    version      = "main"
    name         = "default-repo"
    auto_init    = true
    has_issues   = true
    has_projects = true
  }

  values = merge(
    local.defaults,
    try(values, {})
  )
}

terraform {
  source = "${local.repository_url}//modules/github-repository?ref=${local.values.version}"
}

inputs = local.values