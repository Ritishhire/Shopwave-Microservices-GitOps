# ==============================================================================
# AWS LOAD BALANCER CONTROLLER (LBC) MODULE
# ==============================================================================
# Why this file exists:
# This module sets up the IAM Role (using IRSA) and installs the AWS Load Balancer 
# Controller via Helm. The controller is responsible for auto-provisioning AWS ALBs 
# when Ingress resources are created in Kubernetes.
# ==============================================================================

# 1. IAM Role for AWS Load Balancer Controller
# Configures IAM Roles for Service Accounts (IRSA) to grant the LBC pods permissions 
# to create and manage ALBs in our AWS account.
module "lbc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.cluster_name}-aws-lbc-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# 2. Kubernetes Service Account for LBC
# Binds the IAM Role created above to the Kubernetes Service Account used by the controller.
resource "kubernetes_service_account" "lbc_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lbc_role.iam_role_arn
    }
  }
}

# 3. Install AWS Load Balancer Controller via Helm
# Installs the controller in the kube-system namespace.
# We configure all values via a clean, readable YAML string block (values) to avoid 
# any 'set' block validation warnings in Terraform.
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2"

  values = [
    <<-EOT
    clusterName: "${var.cluster_name}"
    serviceAccount:
      create: false
      name: "${kubernetes_service_account.lbc_sa.metadata[0].name}"
    region: "${var.aws_region}"
    vpcId: "${var.vpc_id}"
    EOT
  ]
}