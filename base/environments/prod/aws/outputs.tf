output "vpc_id" {
  description = "ID da VPC"
  value       = module.rede.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.rede.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.rede.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = module.compute.public_ip
}

output "ec2_private_ip" {
  description = "IP privado da instância EC2"
  value       = module.compute.private_ip
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.storage.bucket_arn
}
