// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

resource "argocd_application" "this" {
  metadata {
    name = "contacts"
  }
  spec {
    destination {
      namespace = "default"
      server    = "https://kubernetes.default.svc"
    }
    source {
      path            = "charts"
      repo_url        = "https://github.com/devops-estudos/contacts.git"
      target_revision = "HEAD"
      helm {
        release_name = "contacts"
      }
    }
  }
}
