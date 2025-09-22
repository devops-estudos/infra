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
          name = "${global.name}-repository"
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
    provider "github" {
      owner = global.owner
    }
  }
}

generate_hcl "versions.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {
    terraform {
      required_version = ">= 1.3.2"
      required_providers {
        github = {
          source  = "integrations/github"
          version = "~> 5.0"
        }
      }
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {
    module "repository" {
      source  = "mineiros-io/repository/github"
      version = "~> 0.18.0"

      name        = global.name
      description = global.description
      visibility  = "public"
    }
  }
}