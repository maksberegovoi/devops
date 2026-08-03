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

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks for RDS security group"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}