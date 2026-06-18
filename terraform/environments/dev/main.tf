# Root Terraform file for the 'dev' environment.
# Coordinates modules and ensures dependency execution.

module "networking" {
  source = "../../modules/networking"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = var.cluster_name
  environment          = var.environment
}

module "security" {
  source = "../../modules/security"

  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = module.networking.vpc_cidr_block
  cluster_name   = var.cluster_name
  environment    = var.environment
}

module "eks" {
  source = "../../modules/eks"

  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  vpc_id                 = module.networking.vpc_id
  private_subnets        = module.networking.private_subnets
  node_security_group_id = module.security.node_security_group_id
  environment            = var.environment
}

module "alb_controller" {
  source = "../../modules/alb-controller"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  vpc_id            = module.networking.vpc_id
  aws_region        = var.aws_region

  depends_on = [module.eks]
}

module "argocd" {
  source = "../../modules/argocd"

  environment = var.environment

  depends_on = [module.eks]
}

module "monitoring" {
  source = "../../modules/monitoring"

  grafana_admin_password = var.grafana_admin_password
  environment            = var.environment

  depends_on = [module.eks]
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = ["shopwave-frontend", "shopwave-backend"]
}