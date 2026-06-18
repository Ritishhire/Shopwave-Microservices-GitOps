resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "6.7.18" # Stable argo-cd helm chart version


  depends_on = [
    aws_eks_node_group.nodes
  ]
}
