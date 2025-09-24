// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "stg-us-east-1-vpc"
    }
  }
}
data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "stg-us-east-1-eks"
    }
  }
}
data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}
data "kubernetes_secret" "argocd-initial-admin-secret" {
  count = var.enable_argocd ? 1 : 0
  depends_on = [
    module.addons.argocd,
  ]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
data "kubernetes_service" "argocd-server" {
  count = var.enable_argocd ? 1 : 0
  depends_on = [
    module.addons.argocd,
  ]
  metadata {
    name      = "argo-cd-argocd-server"
    namespace = "argocd"
  }
}
