// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

resource "argocd_application" "this" {
  metadata {
    name = "deals"
  }
  spec {
    destination {
      namespace = "default"
      server    = "https://kubernetes.default.svc"
    }
    source {
      path            = "charts"
      repo_url        = "https://github.com/devops-estudos/deals.git"
      target_revision = "HEAD"
      helm {
        release_name = "deals"
      }
    }
  }
}
