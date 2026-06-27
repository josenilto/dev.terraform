locals {
  bucket_name = "${var.project_name}-${var.environment}-${var.bucket_suffix}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# ── Bucket ────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = merge(local.common_tags, {
    Name = local.bucket_name
  })
}

# ── Versionamento ─────────────────────────────────────────────────────────────

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# ── Criptografia ──────────────────────────────────────────────────────────────

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count  = var.server_side_encryption ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ── Bloqueio de acesso público ────────────────────────────────────────────────

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── Lifecycle (expiração de versões antigas) ──────────────────────────────────

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count  = var.lifecycle_noncurrent_expiration_days > 0 ? 1 : 0
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_noncurrent_expiration_days
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}
