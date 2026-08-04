output "s3_bucket_name" {
  description = "Name of the S3 state bucket"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB locks table"
  value       = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the created ECR repository"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "db_endpoint" {
  description = "Endpoint address for the RDS database"
  value       = module.rds.endpoint
}