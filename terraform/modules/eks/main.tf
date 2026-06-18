# Provisions the AWS EKS Cluster and Managed Node Groups using the official AWS EKS Module.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.private_subnets

  # Disable default security group rules creation to use custom node security group
  node_security_group_id = var.node_security_group_id

  # Enable OIDC provider for IAM Roles for Service Accounts (IRSA)
  enable_irsa = true

  # Grant the IAM identity creating the EKS cluster administrative permissions (Required in EKS module v20+)
  enable_cluster_creator_admin_permissions = true

  # Managed Node Groups configuration
  eks_managed_node_groups = {
    general = {
      name         = "general-nodes"
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["c7i-flex.large"] # c7i-flex.large provides 2 vCPUs and 4GB RAM (highly stable for Prometheus/ArgoCD stack)
      ami_type       = "AL2023_x86_64_STANDARD" # Amazon Linux 2023 supports newer c7i-flex instances
      capacity_type  = "SPOT"

      update_config = {
        max_unavailable = 1
      }

      tags = {
        Environment = var.environment
      }
    }
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

# ==============================================================================
# AWS EBS CSI DRIVER CONFIGURATION (ADD-ON)
# ==============================================================================
# Why this exists:
# By default, newer EKS versions (1.23+) do NOT install the Amazon EBS CSI driver.
# Without it, EKS cannot dynamically provision S3/EBS storage volumes for PVCs 
# (like the 10GB disk space Prometheus needs for storage). 
# This module and resource install the EBS CSI driver and grant it IAM permissions.
# ==============================================================================

# 1. IAM Role for EBS CSI Driver
# Creates a role allowing the driver pods to call AWS EC2 APIs to create, delete, 
# and attach EBS volumes.
module "ebs_csi_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.cluster_name}-ebs-csi-role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# 2. EKS Addon for EBS CSI Driver
# Deploys the driver to the EKS cluster, using the service account role created above.
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_role.iam_role_arn
}
