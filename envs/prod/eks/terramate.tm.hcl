stack {
  name        = "envs/dev/eks"
  description = "Development environment"
  id          = "d5047c92-dd02-47bb-92dc-3b5628532227"

  tags = [
    "aws",
    "dev",
    "eks",
  ]

  after = ["tag:vpc"]
}