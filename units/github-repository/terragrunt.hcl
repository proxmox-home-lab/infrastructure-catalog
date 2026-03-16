include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repository_url = "github.com/proxmox-home-lab/infrastructure-catalog.git"

  defaults = {
    version      = "main"
    name         = "default-repo"
    auto_init    = true
    has_issues   = true
    has_projects = true
  }

  # Org-standard branch protection applied to every repo using this unit.
  # Callers can override a ruleset by using the same key, or add new ones with a different key.
  default_rulesets = {
    default_branch_protection = {
      name        = "default-branch-protection"
      target      = "branch"
      enforcement = "active"
      bypass_actors = []
      conditions = {
        ref_name = {
          include = ["~DEFAULT_BRANCH"]
          exclude = []
        }
      }
      rules = {
        deletion         = true
        non_fast_forward = true
        pull_request = {
          dismiss_stale_reviews_on_push     = true
          require_code_owner_review         = false
          require_last_push_approval        = false
          required_approving_review_count   = 1
          required_review_thread_resolution = false
        }
      }
    }
  }

  caller_values = try(values, {})

  merged = merge(
    local.defaults,
    local.caller_values,
    {
      rulesets = merge(local.default_rulesets, try(local.caller_values.rulesets, {}))
    }
  )
}

terraform {
  source = "${local.repository_url}//modules/github-repository?ref=${local.merged.version}"
}

inputs = local.merged