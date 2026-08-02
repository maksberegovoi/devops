variable "chart_version" {
  description = "Helm chart version for Argo CD"
  type        = string
  default     = "6.7.18"
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "repo_url" {
  description = "Git Repository URL with target Helm chart"
  type        = string
  default     = "https://github.com/maxim/devops.git"
}
