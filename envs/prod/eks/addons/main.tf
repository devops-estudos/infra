// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "addons" {
  argo_rollouts = {
    repository    = "https://argoproj.github.io/argo-helm"
    chart_version = "2.40.4"
    values = [
      file("./configs/argo-rollouts.yml"),
    ]
  }
  argocd = {
    repository    = "https://argoproj.github.io/argo-helm"
    chart_version = "8.5.4"
    values = [
      file("./configs/argocd.yml"),
    ]
  }
  aws_gateway_api_controller = {
    set = [
      {
        name  = "clusterVpcId"
        value = data.terraform_remote_state.vpc.outputs.vpc_id
      },
    ]
  }
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = data.terraform_remote_state.vpc.outputs.vpc_id
      },
    ]
  }
  cluster_endpoint                    = data.terraform_remote_state.eks.outputs.cluster_endpoint
  cluster_name                        = data.terraform_remote_state.eks.outputs.cluster_name
  cluster_version                     = data.terraform_remote_state.eks.outputs.cluster_version
  enable_argo_rollouts                = true
  enable_argocd                       = true
  enable_aws_gateway_api_controller   = true
  enable_aws_load_balancer_controller = true
  oidc_provider_arn                   = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  source                              = "aws-ia/eks-blueprints-addons/aws"
  version                             = "~> 1.0"
}
resource "helm_release" "traefik" {
  chart      = "traefik"
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  values = [
    file("./configs/traefik.yml"),
  ]
  version = "37.1.1"
}
resource "kubernetes_manifest" "datadog" {
  manifest = yamldecode(file("./configs/datadog.yml"))
}
