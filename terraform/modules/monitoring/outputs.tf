output "monitoring_namespace" {
  description = "The namespace monitoring is installed in"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}