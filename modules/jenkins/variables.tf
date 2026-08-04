variable "chart_version" {
  description = "Helm chart version for Jenkins"
  type        = string
  default     = "5.1.4"
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "github_token" {
  description = "GitHub Personal Access Token for pushing chart updates"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "EKS Cluster Name for IRSA role naming"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN for EKS IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC Provider URL for EKS IRSA"
  type        = string
}