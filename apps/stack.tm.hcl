globals {
  project = "contacts"
  owner   = "squad-contacts"
}

generate_hcl "_terramate_generated_main.tf" {
  content {
    module "repository" {
      source  = "mineiros-io/repository/github"
      version = "~> 0.18.0"

      name       = "${global.project}"
      visibility = "public"
    }

    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "6.0.1"

      name = "${global.project}-vpc"
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

      subnet_ids = module.vpc.public_subnets
      vpc_id     = module.vpc.vpc_id

      name               = "${global.project}-eks"
      kubernetes_version = "1.33"

      endpoint_public_access                   = true
      enable_cluster_creator_admin_permissions = true
      enable_irsa                              = true

      zonal_shift_config = {
        enabled = true
      }

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

    }

    module "github-oidc" {
      source  = "terraform-module/github-oidc-provider/aws"
      version = "2.2.1"

      create_oidc_provider = true
      create_oidc_role     = true

      repositories              = [module.repository.full_name]
      oidc_role_attach_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }

    module "ecr" {
      source  = "terraform-aws-modules/ecr/aws"
      version = "3.0.1"

      repository_name = "${global.project}"

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
  }
}