// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "ecr" {
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      },
    ]
  })
  repository_name = "deals"
  source          = "terraform-aws-modules/ecr/aws"
  version         = "3.0.1"
}
