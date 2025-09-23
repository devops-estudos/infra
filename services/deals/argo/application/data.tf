// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "dev-us-east-1-eks"
    }
  }
}
data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}
data "kubernetes_secret" "argocd-initial-admin-secret" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}
data "kubernetes_service" "argocd-server" {
  metadata {
    name      = "argo-cd-argocd-server"
    namespace = "argocd"
  }
}
