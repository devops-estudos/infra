stack {
  name = "network/prod"
  id   = "b170e1c2-0f2f-431e-9772-74452c1500bc"
}

globals {
  environment = "prod"
}

output "vpc_id" {
  backend = "default"
  value   = module.vpc.vpc_id
}

output "public_subnets" {
  backend = "default"
  value   = module.vpc.public_subnets
}