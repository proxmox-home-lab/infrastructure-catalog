# Infrastructure as Code Catalog

Infrastructure Catalog which contains reusable Terraform &amp; Terragrunt code

## Terraform Modules

| Module                      | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `modules/github-repository` | GitHub repository module for managing repositories  |
| `modules/github-teams`      | GitHub teams module for managing Organization teams |

## Terragrunt Units

| Unit                      | Description                                       | Modules consumed            |
| ------------------------- | ------------------------------------------------- | --------------------------- |
| `units/github-repository` | GitHub repository unit for managing repositories  | `modules/github-repository` |
| `units/github-teams`      | GitHub teams unit for managing Organization teams | `modules/github-teams`      |
