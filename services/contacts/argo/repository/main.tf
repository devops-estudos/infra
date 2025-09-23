// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

resource "argocd_repository" "this" {
  name    = "contacts"
  project = "default"
  repo    = "https://github.com/devops-estudos/contacts.git"
  type    = "git"
}
