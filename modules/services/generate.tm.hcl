# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["services/**"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.name}-service"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["services/**"]
  }
  content {
    provider "aws" {
      region = global.region
    }

    provider "github" {
      owner = global.owner
    }
  }
}

generate_hcl "versions.tf" {
  stack_filter {
    project_paths = ["services/**"]
  }
  content {
    terraform {
    }
    terraform {
      required_version = ">= 1.3.2"

      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 6.0"
        }
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
    project_paths = ["services/**"]
  }
  content {
    module "repository" {
      source  = "mineiros-io/repository/github"
      version = "~> 0.18.0"

      name        = global.name
      description = "Repository for ${global.name} service"

      visibility = "public"
    }

    module "ecr" {
      source  = "terraform-aws-modules/ecr/aws"
      version = "3.0.1"

      repository_name = global.name

      repository_lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1,
            description  = "Keep last 10 images",
            selection = {
              tagStatus   = "any",
              countType   = "imageCountMoreThan",
              countNumber = 10
            },
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
  }
}