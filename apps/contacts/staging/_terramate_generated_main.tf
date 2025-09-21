// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "vpc" {
  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
  cidr                    = "10.0.0.0/16"
  map_public_ip_on_launch = true
  name                    = "contacts-us-east-1-production-vpc"
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]
  single_nat_gateway = true
  source             = "terraform-aws-modules/vpc/aws"
  version            = "6.0.1"
}
module "eks" {
  eks_managed_node_groups = {
    main = {
      capacity_type = "SPOT"
      desired_size  = 1
      instance_types = [
        "t3a.medium",
      ]
      max_size = 1
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
  name                                     = "contacts-us-east-1-production-eks"
  source                                   = "terraform-aws-modules/eks/aws"
  subnet_ids                               = module.vpc.public_subnets
  version                                  = "21.2.0"
  vpc_id                                   = module.vpc.vpc_id
  zonal_shift_config = {
    enabled = true
  }
}
module "github-oidc" {
  create_oidc_provider = true
  create_oidc_role     = true
  oidc_role_attach_policies = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  repositories = [
  ]
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"
}
module "ecr" {
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
  repository_name = "contacts"
  source          = "terraform-aws-modules/ecr/aws"
  version         = "3.0.1"
}
