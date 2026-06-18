# ==============================================================================
# PROVIDERS CONFIGURATION FILE
# ==============================================================================
# Why this file exists:
# In Terraform, "Providers" are plugins that allow Terraform to communicate with 
# external APIs (like AWS, Kubernetes, Helm, etc.). This file declares the providers 
# we need, installs them, and configures how they authenticate.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"
  
  # Declares which provider plugins are required and where to download them
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# 1. AWS Provider
# Configures the connection to AWS using the specified region (e.g. us-east-1).
provider "aws" {
  region = var.aws_region
}

# 3. Kubernetes Provider
# Tells Terraform how to talk to the newly created EKS Cluster.
# We use the exec plugin to fetch the token dynamically, preventing token expiration during long applies.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
  }
}

# 4. Helm Provider
# Allows Terraform to install Helm charts (like ArgoCD and Prometheus) onto EKS.
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.aws_region]
    }
  }
}
