variable "aws_region" {
  description = "AWS Region to deploy bootstrap resources"
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform remote state (must be globally unique)"
  type        = string
  default     = "shopwave-tfstate-bucket"
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "shopwave-tflocks"
}