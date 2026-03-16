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
      name          = "default-branch-protection"
      target        = "branch"
      enforcement   = "active"
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
          require_code_owner_review         = true
          require_last_push_approval        = false
          required_approving_review_count   = 1
          required_review_thread_resolution = false
        }
      }
    }
  }

  # Org-standard CODEOWNERS baseline: CI/CD paths always require platform review,
  # regardless of who owns the rest of the repo.
  # Stack entries are appended after this baseline (last-match-wins in GitHub).
  default_codeowners = [
    "/.github/ @proxmox-home-lab/platform",
  ]

  caller_values = try(values, {})

  # import_id is a Terragrunt-only field used to generate an OpenTofu import block
  # for repos that already exist in GitHub. Stripped before passing inputs to Terraform.
  import_id = try(local.caller_values.import_id, "")

  merged = merge(
    local.defaults,
    { for k, v in local.caller_values : k => v if k != "import_id" },
    {
      rulesets   = merge(local.default_rulesets, try(local.caller_values.rulesets, {}))
      codeowners = concat(local.default_codeowners, try(local.caller_values.codeowners, []))
    }
  )
}

# Generates an OpenTofu import block when import_id is provided.
# Needed for repos that already exist in GitHub and must be brought into IaC state.
# Safe to leave permanently: OpenTofu ignores the block if the resource is already in state.
generate "imports" {
  path      = "imports.tf"
  if_exists = "overwrite"
  contents = local.import_id != "" ? join("\n", [
    "import {",
    "  to = github_repository.default[0]",
    "  id = \"${local.import_id}\"",
    "}",
  ]) : ""
}

terraform {
  source = "${local.repository_url}//modules/github-repository?ref=${local.merged.version}"
}

inputs = local.merged
