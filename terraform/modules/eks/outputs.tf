output "cluster_name" {
  description = "The EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The EKS Cluster Control Plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "The EKS Cluster CA cert data"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider" {
  description = "The URL of the OIDC Provider for IRSA"
  value       = module.eks.oidc_provider
}