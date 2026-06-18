variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to deploy subnets in"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster to tag subnets for discovery"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}