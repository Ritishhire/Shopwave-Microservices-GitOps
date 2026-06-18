terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# ==============================================================================
# ARGOCD MODULE
# ==============================================================================
# Why this file exists:
# This module installs ArgoCD (the GitOps engine) and ArgoCD Image Updater 
# (which auto-detects new docker tags) into our EKS cluster.
# ==============================================================================

# 1. Create ArgoCD Namespace
# A namespace is like a virtual folder in Kubernetes to isolate resources.
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# 2. Install ArgoCD using Helm
# We deploy ArgoCD via Helm. We configure the server service to run as ClusterIP.
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "6.7.18" # Stable modern version

  values = [
    <<-EOT
    server:
      service:
        type: ClusterIP # Exposes server internally, to be accessed via Ingress later
    notifications:
      enabled: true
      secret:
        create: true
        items:
          github-token: "<YOUR_GITHUB_TOKEN>"
      notifiers:
        ext.github: |
          token: $github-token
      cm:
        create: true
        trigger.on-deployed: |
          - send: [github]
            when: app.status.sync.status == 'Synced' and app.status.health.status == 'Healthy'
        trigger.on-health-degraded: |
          - send: [github]
            when: app.status.health.status == 'Degraded'
    EOT
  ]
}

# 3. Install ArgoCD Image Updater using Helm
# This controller polls the docker registry, detects new versions of our 
# backend/frontend images, and writes those updates back to Git automatically.
resource "helm_release" "argocd_image_updater" {
  name       = "argocd-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "0.9.1"

  # Depend on core ArgoCD installation to make sure CRDs exist first
  depends_on = [helm_release.argocd]

  values = [
    <<-EOT
    config:
      argocd:
        image-updater:
          interval: 2m # Checks for new images every 2 minutes
      registries:
        - name: ECR
          api_url: https://*.dkr.ecr.*.amazonaws.com
          prefix: "*.dkr.ecr.*.amazonaws.com"
          ping: yes
          credentials: ext:/scripts/ecr-login.sh
          credsexpire: 10h
    authScripts:
      enabled: true
      scripts:
        ecr-login.sh: |
          #!/bin/sh
          aws ecr get-login-password --region ap-south-1
    EOT
  ]
}