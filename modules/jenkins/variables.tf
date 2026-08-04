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

variable "aws_access_key_id" {
  description = "AWS Access Key ID for ECR push"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for ECR push"
  type        = string
  sensitive   = true
}
