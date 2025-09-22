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
          name = "${global.env}-${global.region}-repository"
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
    provider "aws" {
      region = global.region
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/repository"]
  }
  content {

  }
}

generate_hcl "output.tf" {
  stack_filter {
    project_paths = ["envs/**/eks"]
  }
  content {
    output "cluster_name" {
      value = module.eks.cluster_name
    }
    output "cluster_endpoint" {
      value = module.eks.cluster_endpoint
    }
    output "cluster_version" {
      value = module.eks.cluster_version
    }
    output "oidc_provider_arn" {
      value = module.eks.oidc_provider_arn
    }
  }
}