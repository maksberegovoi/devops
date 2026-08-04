locals {
  actual_engine = var.use_aurora ? (
    var.engine == "postgres" ? "aurora-postgresql" : (
      var.engine == "mysql" ? "aurora-mysql" : var.engine
    )
  ) : var.engine

  db_family = var.use_aurora ? (
    startswith(local.actual_engine, "aurora-postgresql") ? "aurora-postgresql15" : "aurora-mysql8.0"
    ) : (
    startswith(local.actual_engine, "postgres") ? "postgres15" : "mysql8.0"
  )
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = "${var.name}-subnet-group" })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Security group for ${var.name} database"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow DB connection from internal network"
    from_port   = endswith(local.actual_engine, "mysql") ? 3306 : 5432
    to_port     = endswith(local.actual_engine, "mysql") ? 3306 : 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg" })
}

resource "aws_db_parameter_group" "single" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name}-rds-pg"
  family = local.db_family

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }

  tags = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-aurora-pg"
  family = local.db_family

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "work_mem"
    value = "4096"
  }

  tags = var.tags
}