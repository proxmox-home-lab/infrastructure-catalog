output "repository_name" {
  description = "The name of the repository."
  value       = join("", github_repository.default[*].name)
}

output "repository_full_name" {
  description = "The full name of the repository (org/repo)."
  value       = join("", github_repository.default[*].full_name)
}

output "repository_html_url" {
  description = "The URL to the repository on GitHub."
  value       = join("", github_repository.default[*].html_url)
}

output "repository_id" {
  description = "The GitHub ID of the repository."
  value       = join("", github_repository.default[*].repo_id)
}

output "default_branch" {
  description = "The default branch of the repository."
  value       = join("", github_branch_default.default[*].branch)
}
