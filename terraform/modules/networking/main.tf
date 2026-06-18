# Modules are best practice for clean separation of concerns.
# This module encapsulates our VPC setup using the official AWS VPC module.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  # Enable NAT Gateway. One NAT Gateway is shared to minimize cost (suitable for dev/portfolio).
  # For absolute high availability in production, set single_nat_gateway = false and one_nat_gateway_per_az = true.
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tag subnets correctly for EKS and AWS Load Balancer Controller auto-discovery
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}