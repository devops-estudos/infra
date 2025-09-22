globals {
  repositories = {
    contacts = {
      name        = "contacts"
      description = "Contacts repository"
    }
  }
}

# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "github-repository"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {
    module "repository" {
      for_each = global.repositories

      source  = "mineiros-io/repository/github"
      version = "~> 0.18.0"

      name        = each.value.name
      description = each.value.description
    }
  }
}