locals {
  services = {
    contacts = {
      name = "contacts"
    }
  }
}

module "ecr" {
  for_each = local.services

  source  = "terraform-aws-modules/ecr/aws"
  version = "3.0.1"

  repository_name = each.value.name

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
