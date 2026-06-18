output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Control Plane endpoint"
  value       = module.eks.cluster_endpoint
}

output "argocd_namespace" {
  description = "ArgoCD Namespace"
  value       = module.argocd.argocd_namespace
}

output "monitoring_namespace" {
  description = "Monitoring Namespace"
  value       = module.monitoring.monitoring_namespace
}