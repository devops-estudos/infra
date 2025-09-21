// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "contacts" {
  description = "Contacts application to be used by my DevOps studies"
  name        = "contacts"
  source      = "mineiros-io/repository/github"
  version     = "~> 0.18.0"
  visibility  = "public"
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
  name                                     = "contacts-eks"
  source                                   = "terraform-aws-modules/eks/aws"
  subnet_ids                               = module.vpc.public_subnets
  version                                  = "21.2.0"
  vpc_id                                   = module.vpc.vpc_id
  zonal_shift_config = {
    enabled = true
  }
}
