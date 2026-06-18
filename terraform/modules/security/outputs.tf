output "cluster_security_group_id" {
  description = "The ID of the cluster control plane security group"
  value       = module.cluster_sg.security_group_id
}

output "node_security_group_id" {
  description = "The ID of the worker node security group"
  value       = module.node_sg.security_group_id
}