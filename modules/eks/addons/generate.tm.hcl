# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.env}-${global.region}-eks-addons"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
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
    project_paths = ["envs/**/eks/addons"]
  }
  content {
    data "terraform_remote_state" "vpc" {
      backend = "remote"

      config = {
        organization = global.organization
        workspaces = {
          name = "${global.env}-${global.region}-vpc"
        }
      }
    }

    data "terraform_remote_state" "eks" {
      backend = "remote"

      config = {
        organization = global.organization
        workspaces = {
          name = "${global.env}-${global.region}-eks"
        }
      }
    }

    module "addons" {
      source  = "aws-ia/eks-blueprints-addons/aws"
      version = "~> 1.0"

      cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
      cluster_endpoint  = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_version   = data.terraform_remote_state.eks.outputs.cluster_version
      oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn



      # enable_argocd = true
      # argocd = {
      #   repository    = "https://argoproj.github.io/argo-helm"
      #   chart_version = "8.3.7"
      #   values        = [templatefile("${path.module}/helm/argocd.yml", {})]
      # }

      enable_aws_load_balancer_controller = true
      aws_load_balancer_controller = {
        set = [
          {
            name  = "vpcId"
            value = data.terraform_remote_state.vpc.outputs.vpc_id
          },
        ]
      }

      enable_aws_gateway_api_controller = true
      aws_gateway_api_controller = {
        set = [{
          name  = "clusterVpcId"
          value = data.terraform_remote_state.vpc.outputs.vpc_id
        }]
      }
    }
  }
}