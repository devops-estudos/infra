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
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
