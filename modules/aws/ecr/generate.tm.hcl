# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/ecr"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.name}-${global.region}-ecr"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["**/ecr"]
  }
  content {
    provider "aws" {
      region = global.region
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/ecr"]
  }
  content {
    module "ecr" {
      source  = "terraform-aws-modules/ecr/aws"
      version = "3.0.1"

      repository_name = global.name

      repository_lifecycle_policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Keep last 10 images"
            selection = {
              tagStatus   = "any"
              countType   = "imageCountMoreThan"
              countNumber = 10
            }
            action = {
              type = "expire"
            }
          },
        ]
      })
    }
  }
}

