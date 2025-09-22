// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

terraform {
  backend "remote" {
    organization = "devops-studies"
    workspaces {
      name = "contacts-service"
    }
  }
}
