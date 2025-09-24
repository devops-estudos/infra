// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "devops-studies"
    workspaces = {
      name = "deals-eks"
    }
  }
}
data "aws_eks_cluster_auth" "cluster_auth" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}
