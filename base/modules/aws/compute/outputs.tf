output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN da instância EC2"
  value       = aws_instance.main.arn
}

output "private_ip" {
  description = "IP privado da instância"
  value       = aws_instance.main.private_ip
}

output "public_ip" {
  description = "IP público da instância (disponível somente em subnet pública)"
  value       = aws_instance.main.public_ip
}

output "instance_type" {
  description = "Tipo da instância provisionada"
  value       = aws_instance.main.instance_type
}
