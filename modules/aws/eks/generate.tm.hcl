# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["**/eks"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.env}-${global.region}-eks"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["envs/**/eks"]
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
    project_paths = ["**/eks"]
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
    module "eks" {
      source  = "terraform-aws-modules/eks/aws"
      version = "21.2.0"

      subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets
      vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id

      name               = "${global.env}-${global.region}-eks"
      kubernetes_version = "1.33"

      endpoint_public_access                   = true
      enable_cluster_creator_admin_permissions = true
      enable_irsa                              = true

      zonal_shift_config = {
        enabled = true
      }

      addons = {
        coredns = {}
        eks-pod-identity-agent = {
          before_compute = true
        }
        kube-proxy = {}
        vpc-cni = {
          before_compute = true
        }
        datadog_operator = {}
        aws-ebs-csi-driver = {}
      }

      eks_managed_node_groups = {
        main = {
          desired_size   = 3
          instance_types = ["t3a.medium"]
          max_size       = 3
          min_size       = 1
        }
        
        es_deals = {
          desired_size   = 3
          instance_types = ["c5d.large"]
          max_size       = 3
          min_size       = 3

          taints = {
            "es-deals" = {
              key    = "dedicated"
              value  = "deals"
              effect = "NO_SCHEDULE"
            }
          }

          labels = {
            "aws.amazon.com/eks-local-ssd" = "true"
          }

          tags = {
            Name = "${global.env}-es-deals"
          }
        }

        es_contatos = {
          desired_size   = 3
          instance_types = ["c5d.large"]
          max_size       = 3
          min_size       = 3

          taints = {
            "es-contatos" = {
              key    = "dedicated"
              value  = "contatos"
              effect = "NO_SCHEDULE"
            }
          }

          labels = {
            "aws.amazon.com/eks-local-ssd" = "true"
          }

          tags = {
            Name = "${global.env}-es-contatos"
          }
        }

        es_chats = {
          desired_size   = 3
          instance_types = ["c5d.large"]
          max_size       = 3
          min_size       = 3

          taints = {
            "es-chats" = {
              key    = "dedicated"
              value  = "chats"
              effect = "NO_SCHEDULE"
            }
          }

          labels = {
            "aws.amazon.com/eks-local-ssd" = "true"
          }
          tags = {
            Name = "${global.env}-es-chats"
          }
        }
      }
    }
  }
}

generate_hcl "output.tf" {
  stack_filter {
    project_paths = ["**/eks"]
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
    output "cluster_certificate_authority_data" {
      value = module.eks.cluster_certificate_authority_data
    }
  }
}