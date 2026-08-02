variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "Helm chart version for kube-prometheus-stack"
  type        = string
  default     = "55.5.0"
}