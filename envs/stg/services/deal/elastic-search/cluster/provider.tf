// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

provider "kubernetes" {
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
