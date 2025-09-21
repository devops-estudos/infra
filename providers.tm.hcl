generate_hcl "_terramate_generated_providers.tf" {
  content {
    provider "aws" {
      region = "us-east-1"

      default_tags {
        tags = {
          Environment = "${global.environment}"
          Project     = "${global.project}"
          Owner       = "${global.owner}"
          CreatedBy   = "terramate"
          ManagedBy   = "terramate"
          Terraform   = "true"
        }
      }
    }

    data "aws_eks_cluster_auth" "cluster_auth" {
      depends_on = [module.eks.cluster_id]
      name       = module.eks.cluster_name
    }
    provider "helm" {
      kubernetes = {
        host                   = module.eks.cluster_endpoint
        cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
        token                  = data.aws_eks_cluster_auth.cluster_auth.token
      }
    }

    provider "kubernetes" {
      host                   = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster_auth.token
    }

    # data "kubernetes_secret" "argocd-initial-admin-secret" {
    #   depends_on = [module.eks_blueprints_addons.argocd]

    #   metadata {
    #     name      = "argocd-initial-admin-secret"
    #     namespace = "argocd"
    #   }
    # }
    # data "kubernetes_service" "argocd-server" {
    #   depends_on = [module.eks_blueprints_addons.argocd]

    #   metadata {
    #     name      = "argo-cd-argocd-server"
    #     namespace = "argocd"
    #   }
    # }

    # provider "argocd" {
    #   server_addr = data.kubernetes_service.argocd-server.status[0].load_balancer[0].ingress[0].hostname
    #   username    = "admin"
    #   password    = data.kubernetes_secret.argocd-initial-admin-secret.data.password

    #   plain_text = true
    #   insecure   = true
    # }

    # provider "github" {
    #   owner = "devops-estudos"
    # }
  }
}