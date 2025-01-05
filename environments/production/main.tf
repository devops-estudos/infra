locals {
  environment  = "production"
  repositories = ["devops-estudos/infra", "devops-estudos/adonis-app", "devops-estudos/nestjs-app", "devops-estudos/k8s"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${local.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
  #   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  map_public_ip_on_launch = true

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${local.environment}-eks"
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3a.medium"]
      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 5
      desired_size = 3
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  tags = {
    Environment = local.environment
    Terraform   = "true"
  }
}

resource "aws_iam_policy" "policy" {
  name        = "AmazonElastiContainerServiceWriteAccess"
  path        = "/"
  description = "Amazon Elastic Container Service Private Write Access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",
        ]
        Resource = "*"
      },
    ]
  })
}
module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = local.repositories
  oidc_role_attach_policies = [aws_iam_policy.policy.arn]
}

module "ecr" {
  for_each = {
    for idx, repo in local.repositories : idx => repo if length(regexall("app", repo)) > 0
  }

  source = "terraform-aws-modules/ecr/aws"

  repository_name = each.value

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = local.environment
  }
}
