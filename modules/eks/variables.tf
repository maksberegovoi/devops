variable "cluster_name" {
  type    = string
  default = "lesson-7-eks"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private or public subnet IDs for EKS nodes"
}