# ── VPC ───────────────────────────────────────────────────────────────────────

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── Subnets ───────────────────────────────────────────────────────────────────

resource "aws_subnet" "subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_a_cidr
  availability_zone       = var.az_a
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-subnet-a"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Role        = "RDS-Master"
  })
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_b_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-subnet-b"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Role        = "RDS-ReadReplica"
  })
}

# ── Internet Gateway ──────────────────────────────────────────────────────────

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── Route Table ───────────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-rt-public"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.subnet_b.id
  route_table_id = aws_route_table.public.id
}

# ── Security Group (VPC Security Group) ──────────────────────────────────────

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg"
  description = "VPC Security Group — acesso PostgreSQL publico ao RDS Master e Read Replica"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "PostgreSQL — acesso publico"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Saida irrestrita"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── DB Subnet Group ───────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-subnetgrp"
  description = "Subnet group cobrindo Subnet A (${var.az_a}) e Subnet B (${var.az_b})"
  subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  tags = merge(var.tags, {
    Name        = "${local.name_prefix}-subnetgrp"
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}
