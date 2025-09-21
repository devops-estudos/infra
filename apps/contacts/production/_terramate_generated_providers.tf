// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      CreatedBy   = "terramate"
      Environment = "production"
      ManagedBy   = "terramate"
      Owner       = "squad-contacts"
      Project     = "contacts"
      Terraform   = "true"
    }
  }
}
data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [
    module.eks.cluster_id,
  ]
  name = module.eks.cluster_name
}
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
data "kubernetes_secret" "argocd-initial-admin-secret" {
  depends_on = [
    module.eks_blueprints_addons.argocd,
  ]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
data "kubernetes_service" "argocd-server" {
  depends_on = [
    module.eks_blueprints_addons.argocd,
  ]
  metadata {
    name      = "argo-cd-argocd-server"
    namespace = "argocd"
  }
}
provider "argocd" {
  insecure    = true
  password    = data.kubernetes_secret.argocd-initial-admin-secret.data.password
  plain_text  = true
  server_addr = data.kubernetes_service.argocd-server.status[0].load_balancer[0].ingress[0].hostname
  username    = "admin"
}
provider "github" {
  owner = "devops-estudos"
}
