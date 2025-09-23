// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

resource "argocd_repository" "this" {
  name    = "deals"
  project = "default"
  repo    = "https://github.com/devops-estudos/deals.git"
  type    = "git"
}
