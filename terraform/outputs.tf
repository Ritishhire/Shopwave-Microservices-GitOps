output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster API server"
  value       = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig_connect_command" {
  description = "Run this command to update your local kubeconfig and connect to EKS"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.cluster.name}"
}

output "argocd_password_retrieval_command" {
  description = "Run this command to retrieve and decode the Argo CD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 --decode"
}
