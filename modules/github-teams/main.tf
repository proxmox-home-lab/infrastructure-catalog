resource "github_team" "this" {
  name           = var.name
  description    = var.description
  privacy        = var.privacy
  parent_team_id = var.parent_team_id
}

resource "github_team_membership" "this" {
  for_each = var.members

  team_id  = github_team.this.id
  username = each.key
  role     = each.value
}
