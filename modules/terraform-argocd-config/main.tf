# resource "argocd_project" "this" {
#   metadata {
#     name = "production"
#   }
  
#   spec {
#     source_repos = ["https://github.com/devops-estudos/infra.git"]
#     destinations = []
#   }
# }

resource "argocd_repository" "this" {
  for_each = var.repositories

  project = "default"

  name = each.value.name
  type = each.value.type
  repo = each.value.repo
}

resource "argocd_application_set" "this" {
  for_each = var.applications

  metadata {
    name = each.value.name
  }

  spec {
    generator {
      list {
        elements = [
          {
            environment = "production"
            application = each.value.name
          },
          {
            environment = "staging"
            application = each.value.name
          },
          {
            environment = "development"
            application = each.value.name
          }
        ]
      }
    }

    template {
      metadata {
        name = "${each.value.name}-{{environment}}"
        labels = {
          environment = "{{environment}}"
        }
      }

      spec {
        project = "default"

        source {
          repo_url        = each.value.repo
          target_revision = "HEAD"
          path            = each.value.path

          helm {
            parameter {
              name = "environment"
              value = "{{environment}}"
            }
            parameter {
              name = "name"
              value = "{{application}}"
            }
          }
        }

        destination {
          server    = "https://kubernetes.default.svc"
          namespace = "default"
        }
      }
    }
  }
}