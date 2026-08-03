variable "cluster_name" {
  type    = string
  default = "lesson-7-eks"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs (optional for cluster endpoint)"
  default     = []
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for worker nodes"
}

