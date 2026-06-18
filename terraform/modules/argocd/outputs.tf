output "argocd_namespace" {
  description = "The namespace ArgoCD is installed in"
  value       = kubernetes_namespace.argocd.metadata[0].name
}