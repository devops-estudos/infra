// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT

module "vpc" {
  azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
  cidr                    = "10.0.0.0/16"
  map_public_ip_on_launch = true
  name                    = "stg-us-east-1-vpc"
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  public_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
  ]
  single_nat_gateway = true
  source             = "terraform-aws-modules/vpc/aws"
  version            = "6.0.1"
}
