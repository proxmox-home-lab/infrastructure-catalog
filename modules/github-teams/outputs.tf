output "team_id" {
  description = "The GitHub ID of the team."
  value       = github_team.this.id
}

output "team_slug" {
  description = "The slug of the team on GitHub."
  value       = github_team.this.slug
}

output "team_name" {
  description = "The name of the team."
  value       = github_team.this.name
}
