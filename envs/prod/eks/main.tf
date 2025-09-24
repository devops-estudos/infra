// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "dev-us-east-1-vpc"
    }
  }
}
module "eks" {
  addons = {
    aws-ebs-csi-driver = {}
    coredns            = {}
    datadog_operator   = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }
  eks_managed_node_groups = {
    es_chats = {
      desired_size = 3
      instance_types = [
        "c5d.large",
      ]
      labels = {
        "aws.amazon.com/eks-local-ssd" = "true"
      }
      max_size = 3
      min_size = 3
      tags = {
        Name = "dev-es-chats"
      }
      taints = {
        es-chats = {
          effect = "NO_SCHEDULE"
          key    = "dedicated"
          value  = "chats"
        }
      }
    }
    es_contatos = {
      desired_size = 3
      instance_types = [
        "c5d.large",
      ]
      labels = {
        "aws.amazon.com/eks-local-ssd" = "true"
      }
      max_size = 3
      min_size = 3
      tags = {
        Name = "dev-es-contatos"
      }
      taints = {
        es-contatos = {
          effect = "NO_SCHEDULE"
          key    = "dedicated"
          value  = "contatos"
        }
      }
    }
    es_deals = {
      desired_size = 3
      instance_types = [
        "c5d.large",
      ]
      labels = {
        "aws.amazon.com/eks-local-ssd" = "true"
      }
      max_size = 3
      min_size = 3
      tags = {
        Name = "dev-es-deals"
      }
      taints = {
        es-deals = {
          effect = "NO_SCHEDULE"
          key    = "dedicated"
          value  = "deals"
        }
      }
    }
    main = {
      desired_size = 3
      instance_types = [
        "t3a.medium",
      ]
      max_size = 3
      min_size = 1
    }
  }
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true
  endpoint_public_access                   = true
  kubernetes_version                       = "1.33"
  name                                     = "dev-us-east-1-eks"
  source                                   = "terraform-aws-modules/eks/aws"
  subnet_ids                               = data.terraform_remote_state.vpc.outputs.public_subnets
  version                                  = "21.2.0"
  vpc_id                                   = data.terraform_remote_state.vpc.outputs.vpc_id
  zonal_shift_config = {
    enabled = true
  }
}
