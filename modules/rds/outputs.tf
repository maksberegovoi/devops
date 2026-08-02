output "endpoint" {
  description = "Connection endpoint for the database"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.this[0].endpoint
}

output "reader_endpoint" {
  description = "Reader endpoint for Aurora cluster (N/A for single RDS)"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].reader_endpoint : null
}

output "port" {
  description = "Database connection port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.this[0].port
}

output "security_group_id" {
  description = "ID of the created Security Group"
  value       = aws_security_group.this.id
}