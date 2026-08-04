variable "jenkins_admin_password" {
  description = "Jenkins admin password"
  type        = string
  sensitive   = true
}

variable "github_pat" {
  description = "GitHub Personal Access Token for Argo CD and Jenkins"
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID for ECR push from Jenkins"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key for ECR push from Jenkins"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Django SECRET_KEY for the application"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for RDS security group"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "use_aurora" {
  description = "Flag to switch between Aurora Cluster (true) and Single RDS Instance (false)"
  type        = bool
  default     = false
}