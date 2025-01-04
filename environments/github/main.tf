module "infra" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "infra"
  description = "Infrastructure to be used by my DevOps studies"
  visibility  = "public"
}

module "python-app" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "python-app"
  description = "A simple Python application to be used by my DevOps studies"
  visibility  = "public"
}

module "node-app" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "node-app"
  description = "A simple Node.js application to be used by my DevOps studies"
  visibility  = "public"
}

module "k8s" {
  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name        = "k8s"
  description = "Kubernetes manifests to be used by my DevOps studies"
  visibility  = "public"
}

