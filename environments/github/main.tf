module "infra" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "infra"
  description = "Infrastructure to be used by my DevOps studies"
  visibility  = "public"
}

module "adonis-app" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "adonis-app"
  description = "A simple Adonis application to be used by my DevOps studies"
  visibility  = "public"
}

module "nestjs-app" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "nestjs-app"
  description = "A simple Nest JS application to be used by my DevOps studies"
  visibility  = "public"
}

module "k8s" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "k8s"
  description = "Kubernetes manifests to be used by my DevOps studies"
  visibility  = "public"
}

# Adicionei na mão na github, não tá sendo gerado pelo terraform
# resource "github_actions_organization_secret" "oidc_arn_role" {
#   visibility      = "all"
#   secret_name     = "OIDC_ARN_ROLE"
# }
