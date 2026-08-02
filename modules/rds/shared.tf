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
    from_port   = var.engine == "mysql" || var.engine == "aurora-mysql" ? 3306 : 5432
    to_port     = var.engine == "mysql" || var.engine == "aurora-mysql" ? 3306 : 5432
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
  family = "${var.engine}${split(".", var.engine_version)[0]}"

  parameter {
    name         = "max_connections"
    value        = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = var.tags
}

resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name}-aurora-pg"
  family = "${var.engine}${split(".", var.engine_version)[0]}"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  tags = var.tags
}