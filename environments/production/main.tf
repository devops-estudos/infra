locals {
  environment = "production"
  # repositories = ["devops-estudos/infra", "devops-estudos/adonis-app", "devops-estudos/nestjs-app", "devops-estudos/k8s"]
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "${local.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  map_public_ip_on_launch = true
  single_nat_gateway      = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.2.0"

  name               = "${local.environment}-eks"
  kubernetes_version = "1.33"

  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  zonal_shift_config = {
    enabled = true
  }

  eks_managed_node_groups = {
    main = {
      instance_types = ["t3a.medium"]
      capacity_type  = "SPOT"
      security_group_ingress_rules = {
        argocd = {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          description = "ArgoCD"
          cidr_ipv4   = "0.0.0.0/0"
          name        = "argocd"
        }
      }

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    coredns = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    datadog_operator = {
      most_recent = true
    }
  }

  enable_argocd = true
  argocd = {
    repository    = "https://argoproj.github.io/argo-helm"
    chart_version = "8.3.7"
    values        = [templatefile("${path.module}/helm/argocd.yml", {})]
  }

  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = module.vpc.vpc_id
      },
    ]
  }

  enable_aws_gateway_api_controller = true
  aws_gateway_api_controller = {
    set = [{
      name  = "clusterVpcId"
      value = module.vpc.vpc_id
    }]
  }
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["devops-estudos/micro-services"]
  oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.0.1"

  repository_name = "contacts"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "kubernetes_secret" "datadog-secret" {
  depends_on = [module.eks_blueprints_addons.datadog_operator]

  metadata {
    name      = "datadog-secret"
    namespace = "datadog-agent"
  }

  data = {
    api-key = "7473a48ff1e8e3e4bd6a5e546350acfb"
    app-key = "dc67678fd9159503d4185225a2ffe8557caa1e30"
  }
}

module "argocd-config" {
  depends_on = [module.eks_blueprints_addons.argocd, kubernetes_secret.datadog-secret]
  source     = "../../modules/terraform-argocd-config"

  repositories = {
    k8s = {
      name = "k8s"
      repo = "https://github.com/devops-estudos/k8s.git"
    }
  }


  applications = {
    contacts = {
      name = "contacts"
      repo = "https://github.com/devops-estudos/k8s.git"
      path = "services/application"
    }
  }
}

resource "github_actions_secret" "oidc_arn_role" {
  repository      = "micro-services"
  secret_name     = "OIDC_ARN_ROLE"
  plaintext_value = module.github-oidc.oidc_role
}

resource "github_actions_variable" "ecr_repository_url" {
  repository    = "micro-services"
  variable_name = "CONTACTS_CONTAINER_REGISTRY"
  value         = module.ecr.repository_url
}
