resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier              = "${var.name}-cluster"
  engine                          = var.engine
  engine_version                  = var.engine_version
  database_name                   = var.db_name
  master_username                 = var.admin_username
  master_password                 = var.admin_password
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora[0].name
  skip_final_snapshot             = true

  tags = merge(var.tags, { Name = "${var.name}-cluster" })
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count = var.use_aurora ? 1 : 0

  identifier           = "${var.name}-instance-1"
  cluster_identifier   = aws_rds_cluster.aurora[0].id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.aurora[0].engine
  engine_version       = aws_rds_cluster.aurora[0].engine_version
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = merge(var.tags, { Name = "${var.name}-instance-1" })
}