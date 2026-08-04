resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "aws_iam_role" "jenkins_irsa" {
  name = "${var.cluster_name}-jenkins-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:jenkins"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "kubernetes_secret" "jenkins_secrets" {
  metadata {
    name      = "jenkins-secrets"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  data = {
    "github-token" = var.github_token
  }

  type = "Opaque"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  timeout = 900
  wait    = false

  values = [
    file("${path.module}/values.yaml")
  ]

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.jenkins_irsa.arn
  }

  depends_on = [kubernetes_secret.jenkins_secrets, aws_iam_role_policy_attachment.jenkins_ecr]
}