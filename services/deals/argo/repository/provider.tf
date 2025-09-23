// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

provider "kubernetes" {
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
provider "argocd" {
  insecure    = true
  password    = data.kubernetes_secret.argocd-initial-admin-secret.data.password
  plain_text  = true
  server_addr = data.kubernetes_service.argocd-server.status[0].load_balancer[0].ingress[0].hostname
  username    = "admin"
}
