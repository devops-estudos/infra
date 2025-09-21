module "repository" {
    source  = "mineiros-io/repository/github"
    version = "~> 0.18.0"

    name       = "contacts"
    visibility = "public"
}