terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "mb-tf-state-164253013547"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_name           = "lesson-7-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-7-ecr"
  scan_on_push = true
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "lesson-7-eks"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "rds" {
  source = "./modules/rds"

  name       = "lesson-8-db"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  use_aurora     = false
  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t4g.micro"

  db_name        = "django_db"
  admin_username = "postgres"
  admin_password = var.db_password

  allowed_cidr_blocks = var.allowed_cidr_blocks

  tags = {
    Environment = "final-project"
    ManagedBy   = "Terraform"
  }
}

module "jenkins" {
  source = "./modules/jenkins"
}

module "argo_cd" {
  source    = "./modules/argo_cd"
  namespace = "argocd"
  repo_url  = "https://github.com/maksberegovoi/devops.git"
}