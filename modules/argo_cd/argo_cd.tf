resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "argocd_apps" {
  name      = "argocd-apps"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  set {
    name  = "repositoryUrl"
    value = var.repo_url
  }

  set {
    name  = "targetRevision"
    value = "HEAD"
  }

  set {
    name  = "chartPath"
    value = "charts/django-app"
  }

  set {
    name  = "destinationNamespace"
    value = "default"
  }

  depends_on = [helm_release.argocd]
}