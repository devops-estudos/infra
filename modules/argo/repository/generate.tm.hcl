# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/argo/repository"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.name}-argo-repository"
        }
      }
    }
  }
}

# data.tf
generate_hcl "data.tf" {
  stack_filter {
    project_paths = ["**/argo/repository"]
  }
  content {
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
      metadata {
        name      = "argocd-initial-admin-secret"
        namespace = "argocd"
      }
    }
    data "kubernetes_service" "argocd-server" {
      metadata {
        name      = "argo-cd-argocd-server"
        namespace = "argocd"
      }
    }
  }
}
# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["**/argo/repository"]
  }
  content {
    provider "kubernetes" {
      host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster_auth.token
    }
    provider "argocd" {
      server_addr = data.kubernetes_service.argocd-server.status[0].load_balancer[0].ingress[0].hostname
      username    = "admin"
      password    = data.kubernetes_secret.argocd-initial-admin-secret.data.password

      plain_text = true
      insecure   = true
    }

  }
}

generate_hcl "versions.tf" {
  stack_filter {
    project_paths = ["**/argo/repository"]
  }
  content {
    terraform {
      required_version = ">= 1.3.2"
      required_providers {
        argocd = {
          source  = "argoproj-labs/argocd"
          version = "~> 7.11.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "~> 2.38.0"
        }
      }
    }
  }
}

# main.tf
generate_hcl "main.tf" {
  stack_filter {
    project_paths = ["**/argo/repository"]
  }
  content {
    resource "argocd_repository" "this" {
      project = "default"

      name = global.name
      type = "git"
      repo = global.repository_url
    }
  }
}