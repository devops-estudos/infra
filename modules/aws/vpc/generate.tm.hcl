# backend.tf
generate_hcl "backend.tf" {
  stack_filter {
    project_paths = ["envs/**/vpc"]
  }
  content {
    terraform {
      backend "remote" {
        organization = global.organization
        workspaces {
          name = "${global.env}-${global.region}-vpc"
        }
      }
    }
  }
}

# provider.tf
generate_hcl "provider.tf" {
  stack_filter {
    project_paths = ["envs/**/vpc"]
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
    project_paths = ["envs/**/vpc"]
  }
  content {
    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "6.0.1"

      name = "${global.env}-${global.region}-vpc"
      cidr = "10.0.0.0/16"

      azs             = ["${global.region}a", "${global.region}b", "${global.region}c"]
      private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

      map_public_ip_on_launch = true
      single_nat_gateway      = true

      public_subnet_tags = {
        "kubernetes.io/role/elb" = "1"
      }
    }
  }
}

generate_hcl "output.tf" {
  stack_filter {
    project_paths = ["envs/**/vpc"]
  }
  content {
    output "vpc_id" {
      value = module.vpc.vpc_id
    }

    output "public_subnets" {
      value = module.vpc.public_subnets
    }

    output "private_subnets" {
      value = module.vpc.private_subnets
    }
  }
}