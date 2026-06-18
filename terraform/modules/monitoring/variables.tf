variable "grafana_admin_password" {
  description = "The admin password for Grafana dashboard"
  type        = string
  default     = "admin123"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}