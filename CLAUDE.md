# infrastructure-catalog — Terraform Module Library

## Purpose

Single source of truth for reusable Terraform modules and their Terragrunt unit
wrappers. Modules define the what (resource logic); units define the how (opinionated
defaults, provider wiring, state configuration). All other repos in the org consume
modules from here via versioned Git references.

---

## Architecture

```
infrastructure-catalog/
│
├── modules/          Pure Terraform — no provider instantiation,
│                     only required_providers. Reusable across any
│                     Terragrunt or plain Terraform context.
│
└── units/            Terragrunt wrappers around modules. Apply org-level
                      defaults, inherit root.hcl state config, expose a
                      simplified interface to stack consumers.
```

**Consumer pattern:**
```hcl
# terragrunt.stack.hcl in another repo
unit "repo-example" {
  source = "github.com/proxmox-home-lab/infrastructure-catalog.git//units/github-repository?ref=v1.2.0"
  path   = "repo-example"
  values = {
    name       = "example"
    visibility = "public"
  }
}
```

---

## Directory Structure

```
infrastructure-catalog/
├── modules/
│   ├── github-repository/
│   │   ├── main.tf                   # github_repository, github_branch_default,
│   │   │                             # github_actions_variable, github_issue_label,
│   │   │                             # github_repository_ruleset resources
│   │   ├── variables.tf              # All inputs with validation blocks
│   │   ├── outputs.tf                # name, full_name, html_url, repo_id, default_branch
│   │   └── terraform.tf              # required_providers (github >= 6.11.0), tf >= 1
│   └── github-teams/
│       ├── main.tf                   # github_team, github_team_membership resources
│       ├── variables.tf              # name, description, privacy, members, parent_team_id
│       ├── outputs.tf                # team_id, team_slug, team_name
│       └── terraform.tf              # required_providers (github >= 6.11.0), tf >= 1
├── units/
│   ├── github-repository/
│   │   └── terragrunt.hcl            # Merges defaults with caller-supplied values,
│   │                                 # references module via ?ref=
│   └── github-teams/
│       └── terragrunt.hcl
├── .gitignore
└── .tflint.hcl                       # TFLint rules: naming, required_version, documented_*
```

---

## Key Files

| File | Description |
|------|-------------|
| `modules/github-repository/main.tf` | Core repository resource + rulesets, labels, variables |
| `modules/github-repository/variables.tf` | 297-line input spec with validation (name format, visibility enum, ruleset structure) |
| `modules/github-teams/main.tf` | Team + membership resources |
| `units/github-repository/terragrunt.hcl` | Unit wrapper: merges `defaults` with caller `values`, sources module via Git ref |
| `units/github-teams/terragrunt.hcl` | Same pattern for teams |
| `.tflint.hcl` | Enforces naming conventions, required docs, typed variables |

---

## Development Workflow

### Adding a new module

1. Create a directory under `modules/<provider>-<resource>/`.
2. Create exactly these files:
   - `terraform.tf` — `required_providers` block only. No `provider` block.
   - `variables.tf` — every input variable must have `description`, `type`, and a
     `validation` block where possible.
   - `main.tf` — resource definitions. Use `count = var.enabled ? 1 : 0` pattern
     for optional resource creation.
   - `outputs.tf` — expose at minimum: the resource ID and any attributes consumers
     will chain into other resources.
3. Create the corresponding unit under `units/<module-name>/terragrunt.hcl`.
4. Open a PR and request review.

### Module file skeleton

```hcl
# terraform.tf
terraform {
  required_version = ">= 1"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.11.0"
    }
  }
}
```

```hcl
# variables.tf  (example)
variable "name" {
  description = "The name of the resource."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Name must be lowercase alphanumeric with hyphens."
  }
}
```

### Unit wrapper pattern

```hcl
# units/<name>/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  values = try(read_terragrunt_config(find_in_parent_folders("terragrunt.values.hcl")).locals, {})

  defaults = {
    enabled     = true
    has_issues  = true
    visibility  = "private"
  }

  merged = merge(local.defaults, local.values)
}

terraform {
  source = "${local.repository_url}//modules/<name>?ref=${local.merged.version}"
}

inputs = local.merged
```

### Running TFLint

```bash
cd infrastructure-catalog/
tflint --init
tflint --recursive
```

---

## Commands Reference

| Command | Context |
|---------|---------|
| `tofu fmt -recursive` | Format all `.tf` files recursively |
| `tofu validate` | Validate a module (run from module directory after `tofu init`) |
| `tflint --recursive` | Run all linting rules across the catalog |
| `tflint --init` | Install TFLint plugins defined in `.tflint.hcl` |

---

## Conventions

**Modules (`modules/`):**
- Exactly 4 files: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tf`. No extra files.
- No `provider` blocks in modules — only `required_providers`.
- No hardcoded values — everything configurable via variables.
- Every variable must have `description` and `type`. Add `validation` for constrained inputs.
- Every output must have `description`.
- Use `count = var.enabled ? 1 : 0` for optional resources.
- Use `for_each` for map-based resources (labels, variables, rulesets).
- Use `join("", resource[*].attr)` to safely dereference count-based resources in outputs.
- **Secrets**: Do not re-enable the `github_actions_secret` block — it is intentionally
  disabled pending Vault Secrets migration. See the comment in `main.tf`.

**Units (`units/`):**
- Always `merge(defaults, values)` — never override without a default.
- `version` default should be `"main"` for development; production stacks must override
  with a semantic tag.
- Inherit state config via `include "root"` — never define a backend directly in a unit.

**Versioning:**
- Keep `main` branch stable and passing. Releases get semantic version tags (`v1.x.x`).
- Consumers in production **must** pin to a version tag, not `main`.
  The current use of `?ref=main` in `.github` repo stacks is a known gap.

---

## Dependencies

**Upstream (what this repo needs):**
- Vault (for provider secrets at apply time, via consuming repos)
- PostgreSQL (remote state, configured in root.hcl of consuming repos)

**Downstream (what consumes this repo):**
- `proxmox-home-lab/.github` — IaC for org management, consumes `units/github-repository`
  and `units/github-teams`

---

## Known Issues / TODOs

- [ ] **No `.tftest.hcl` tests** — modules have no automated test coverage.
  Add integration tests using `tofu test` (OpenTofu 1.6+ feature).
- [ ] **No terraform-docs** — module documentation is not auto-generated.
  Consider adding `.terraform-docs.yml` and a CI step to enforce up-to-date READMEs.
- [ ] **`?ref=main` default in units** — the `version` default should eventually be
  removed in favour of requiring explicit version pinning at the stack level.
