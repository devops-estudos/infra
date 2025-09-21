locals {
  service_dirs = fileset("${path.module}/services", "*")
  services = {
    contacts = {
      name = "contacts"
    }
  }
}

module "repositories" {
  for_each = local.services

  source  = "mineiros-io/repository/github"
  version = "~> 0.18.0"

  name       = each.value.name
  visibility = "public"
}
