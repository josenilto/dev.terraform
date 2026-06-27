output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.main.bucket
}

output "bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Endpoint global do bucket (s3.amazonaws.com)"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Endpoint regional do bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}
