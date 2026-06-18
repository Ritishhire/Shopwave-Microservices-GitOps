variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Kubernetes Version"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

variable "node_security_group_id" {
  description = "Security Group ID to associate with EKS nodes"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}