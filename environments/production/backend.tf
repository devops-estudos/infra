terraform {
  cloud {
    organization = "devops-studies"

    workspaces {
      name = "production"
    }
  }
}
