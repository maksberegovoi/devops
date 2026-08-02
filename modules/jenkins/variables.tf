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

