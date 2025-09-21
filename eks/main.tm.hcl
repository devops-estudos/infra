generate_hcl "main.tf" {
  content {
    module "eks" {
      source  = "terraform-aws-modules/eks/aws"
      version = "21.2.0"

      subnet_ids = module.vpc.public_subnets
      vpc_id     = module.vpc.vpc_id

      name               = "${global.environment}-us-east-1-eks"
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

  }
}