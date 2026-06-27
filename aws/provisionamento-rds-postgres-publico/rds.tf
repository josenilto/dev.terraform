# ── Parameter Group ───────────────────────────────────────────────────────────

resource "aws_db_parameter_group" "postgres" {
  name        = "${local.name_prefix}-pg"
  family      = "postgres${split(".", var.db_engine_version)[0]}"
  description = "Parameter group para PostgreSQL ${var.db_engine_version}"

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-pg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── RDS Master (Read/Write — Subnet A / Availability Zone 1) ─────────────────

resource "aws_db_instance" "master" {
  identifier = local.db_identifier

  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_port

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp2"
  storage_encrypted     = var.db_storage_encrypted

  availability_zone      = var.az_a
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true

  parameter_group_name = aws_db_parameter_group.postgres.name

  backup_retention_period = var.db_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  multi_az             = var.db_multi_az
  deletion_protection  = var.db_deletion_protection
  skip_final_snapshot  = var.skip_final_snapshot
  apply_immediately    = var.db_apply_immediately

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${local.db_identifier}-final-snapshot"

  tags = merge(var.tags, {
    Name        = local.db_identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
    Role        = "Master"
    Access      = "ReadWrite"
    AZ          = var.az_a
  })
}

# ── RDS Read Replica (Read-Only — Subnet B / Availability Zone 2) ─────────────

resource "aws_db_instance" "replica" {
  identifier = local.db_replica_identifier

  replicate_source_db = aws_db_instance.master.identifier
  instance_class      = var.db_instance_class

  availability_zone      = var.az_b
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true

  parameter_group_name = aws_db_parameter_group.postgres.name

  backup_retention_period = 0
  skip_final_snapshot     = true
  apply_immediately       = var.db_apply_immediately

  tags = merge(var.tags, {
    Name        = local.db_replica_identifier
    Environment = var.environment
    ManagedBy   = "Terraform"
    Role        = "ReadReplica"
    Access      = "ReadOnly"
    AZ          = var.az_b
  })
}
