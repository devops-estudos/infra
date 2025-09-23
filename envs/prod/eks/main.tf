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
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }
  eks_managed_node_groups = {
    main = {
      desired_size = 3
      instance_types = [
        "t3a.medium",
      ]
      max_size = 3
      min_size = 1
      security_group_ingress_rules = {
        argocd = {
          cidr_ipv4   = "0.0.0.0/0"
          description = "ArgoCD"
          from_port   = 8080
          name        = "argocd"
          protocol    = "tcp"
          to_port     = 8080
        }
      }
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
