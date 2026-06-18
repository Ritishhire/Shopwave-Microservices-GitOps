terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
  # Local backend is used for this setup. For true production environments,
  # it is highly recommended to configure a remote S3 backend with DynamoDB locking.
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "state/eks/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "terraform-lock-table"
  # }
}

provider "aws" {
  region = var.aws_region
}

# Dynamic authentication for Kubernetes provider using EKS cluster credentials
provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Dynamic authentication for Helm provider using EKS cluster credentials
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}
