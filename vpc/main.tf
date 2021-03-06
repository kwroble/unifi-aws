#############################################################################
# DATA SOURCES
#############################################################################

data "aws_availability_zones" "azs" {}

#############################################################################
# RESOURCES
#############################################################################  

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">=3.11.0"

  name = "unifi-vpc"
  cidr = var.vpc_cidr_range

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs            = slice(data.aws_availability_zones.azs.names, 0, 2)
  public_subnets = var.public_subnets

  tags = {
    Environment = "unifi"
    Team        = "infra"
  }

}

#############################################################################
# OUTPUTS
#############################################################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "nat_public_ips"{
  value = module.vpc.nat_public_ips
}


