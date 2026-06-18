variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of EKS OIDC Provider"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}