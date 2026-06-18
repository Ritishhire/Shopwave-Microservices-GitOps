output "repository_urls" {
  description = "The URLs of the repositories"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}
