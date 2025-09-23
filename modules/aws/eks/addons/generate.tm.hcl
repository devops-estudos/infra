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

    provider "helm" {
      kubernetes {
        host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
        cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
        token                  = data.aws_eks_cluster_auth.cluster_auth.token
      }
    }
    provider "kubernetes" {
      host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster_auth.token
    }
  }
}

# data.tf
generate_hcl "data.tf" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
  }
  content {
    ## Remote states
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

    ## EKS Cluster Auth
    data "aws_eks_cluster_auth" "cluster_auth" {
      name = data.terraform_remote_state.eks.outputs.cluster_name
    }

    ## ArgoCD
    data "kubernetes_secret" "argocd-initial-admin-secret" {
      depends_on = [module.addons.argocd]
      metadata {
        name      = "argocd-initial-admin-secret"
        namespace = "argocd"
      }
    }
    data "kubernetes_service" "argocd-server" {
      depends_on = [module.addons.argocd]

      metadata {
        name      = "argo-cd-argocd-server"
        namespace = "argocd"
      }
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
  }
  content {
    module "addons" {
      source  = "aws-ia/eks-blueprints-addons/aws"
      version = "~> 1.0"

      cluster_name      = data.terraform_remote_state.eks.outputs.cluster_name
      cluster_endpoint  = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_version   = data.terraform_remote_state.eks.outputs.cluster_version
      oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

      enable_argocd = true
      argocd = {
        repository    = "https://argoproj.github.io/argo-helm"
        chart_version = "8.5.4"
        values        = [file("./configs/argocd.yml")]
      }

      enable_argo_rollouts = true
      argo_rollouts = {
        repository    = "https://argoproj.github.io/argo-helm"
        chart_version = "2.40.4"
        values        = []
      }

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

generate_hcl "versions.tf" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
  }
  content {
    terraform {
      required_version = ">= 1.3.2"

      required_providers {
      }
    }
  }
}

generate_file "configs/argocd.yml" {
  stack_filter {
    project_paths = ["envs/**/eks/addons"]
  }

  content = <<-EOF
  configs:
    params:
      server.insecure: true
  server:
    service:
      type: LoadBalancer
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: nlb
        service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
        service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  EOF
}
