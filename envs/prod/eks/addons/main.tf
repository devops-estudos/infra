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
data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "dev-us-east-1-eks"
    }
  }
}
module "addons" {
  aws_gateway_api_controller = {
    set = [
      {
        name  = "clusterVpcId"
        value = data.terraform_remote_state.vpc.outputs.vpc_id
      },
    ]
  }
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = data.terraform_remote_state.vpc.outputs.vpc_id
      },
    ]
  }
  cluster_endpoint                    = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_name                        = data.terraform_remote_state.eks.outputs.cluster_name
  cluster_version                     = data.terraform_remote_state.eks.outputs.cluster_version
  enable_aws_gateway_api_controller   = true
  enable_aws_load_balancer_controller = true
  oidc_provider_arn                   = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  source                              = "aws-ia/eks-blueprints-addons/aws"
  version                             = "~> 1.0"
}
