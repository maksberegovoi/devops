variable "name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "main-db"
}

variable "vpc_id" {
  description = "VPC ID where Database resources will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB Subnet Group (Private subnets required)"
  type        = list(string)
}

variable "use_aurora" {
  description = "Flag to switch between Aurora Cluster (true) and Single RDS Instance (false)"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Database engine type (e.g., postgres, mysql, aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "instance_class" {
  description = "Instance type for RDS or Aurora node (e.g., db.t4g.micro)"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (Used only for Single RDS Instance)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "app_db"
}

variable "admin_username" {
  description = "Master database username"
  type        = string
  default     = "db_admin"
}

variable "admin_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment (Used only for Single RDS Instance)"
  type        = bool
  default     = false
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks to access DB Security Group"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "A mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}