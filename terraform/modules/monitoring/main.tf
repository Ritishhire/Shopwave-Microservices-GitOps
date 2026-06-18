# ==============================================================================
# MONITORING MODULE
# ==============================================================================
# Why this file exists:
# This module installs the Kube-Prometheus-Stack (Prometheus Operator, Prometheus, 
# Alertmanager, Node Exporter, and Grafana) to monitor our cluster and apps.
# ==============================================================================

# 1. Create Monitoring Namespace
# Isolates monitoring pods (Prometheus, Grafana) from other namespaces.
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# 2. Install Kube-Prometheus-Stack using Helm
# We configure Grafana credentials and storage classes using a clean, readable YAML block.
resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "58.1.3" # Stable, feature-rich version

  values = [
    <<-EOT
    # Grafana Dashboard configuration
    grafana:
      adminPassword: "${var.grafana_admin_password}"
      service:
        type: ClusterIP # Internal routing, accessed via Ingress
        
    # Prometheus server configurations and data persistence
    prometheus:
      prometheusSpec:
        storageSpec:
          volumeClaimTemplate:
            spec:
              storageClassName: "gp2" # Standard EBS Storage Class in EKS
              resources:
                requests:
                  storage: 10Gi # 10GB disk space allocated for metrics retention
    EOT
  ]
}