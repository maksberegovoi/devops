resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "jenkins_secrets" {
  metadata {
    name      = "jenkins-secrets"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "github-token"          = var.github_token
    "aws-access-key-id"     = var.aws_access_key_id
    "aws-secret-access-key" = var.aws_secret_access_key
  }

  type = "Opaque"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  timeout    = 900 
  wait       = false

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [kubernetes_secret.jenkins_secrets]
}
