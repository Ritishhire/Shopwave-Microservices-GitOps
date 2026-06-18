# Encapsulates Security Group settings using official AWS SG module.
# Separates cluster traffic, node traffic, and database/internal traffic.

# 1. Cluster Security Group (EKS Control Plane)
module "cluster_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  # Allow inbound HTTPS from VPC
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS access to API Server"
      cidr_blocks = var.vpc_cidr_block
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
  }
}

# 2. Node Security Group (Worker Nodes)
module "node_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.cluster_name}-node-sg"
  description = "EKS worker nodes security group"
  vpc_id      = var.vpc_id

  # Allow node-to-node traffic for pods communication
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  # Allow control plane to communicate with nodes (kubelet, execution)
  ingress_with_source_security_group_id = [
    {
      from_port                = 10250
      to_port                  = 10250
      protocol                 = "tcp"
      description              = "Allow Kubelet from Control Plane"
      source_security_group_id = module.cluster_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Allow HTTPS from Control Plane"
      source_security_group_id = module.cluster_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Environment                                 = var.environment
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}