variable "repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default     = ["shopwave-frontend", "shopwave-backend"]
}
