stack {
  name = "eks/prod"
  id   = "9684d5fc-98d8-4336-ac25-e3e6b42cbfb1"
}

globals {
  environment = "prod"
}

input "vpc_id" {
  backend       = "default"
  from_stack_id = "b170e1c2-0f2f-431e-9772-74452c1500bc"
  value         = outputs.vpc_id.value
}

input "public_subnets" {
  backend       = "default"
  from_stack_id = "b170e1c2-0f2f-431e-9772-74452c1500bc"
  value         = outputs.public_subnets.value
}