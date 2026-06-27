output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do cluster EKS"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "CA certificate do cluster EKS"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Versão do Kubernetes no cluster EKS"
  value       = aws_eks_cluster.main.version
}

output "cluster_oidc_issuer_url" {
  description = "URL do OIDC provider para IRSA"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN do OIDC provider para criação de IAM roles com IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "vpc_id" {
  description = "ID da VPC do cluster EKS"
  value       = aws_vpc.eks.id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "node_iam_role_arn" {
  description = "ARN do IAM Role dos nós EC2"
  value       = aws_iam_role.eks_nodes.arn
}

output "fargate_role_arn" {
  description = "ARN do IAM Role de execução do Fargate"
  value       = aws_iam_role.fargate.arn
}

output "ecr_repository_urls" {
  description = "URLs dos repositórios ECR criados"
  value = {
    for name, repo in aws_ecr_repository.apps : name => repo.repository_url
  }
}

output "cluster_autoscaler_role_arn" {
  description = "ARN do IAM Role do Cluster Autoscaler (IRSA)"
  value       = aws_iam_role.cluster_autoscaler.arn
}

output "ebs_csi_role_arn" {
  description = "ARN do IAM Role do EBS CSI Driver (IRSA)"
  value       = aws_iam_role.ebs_csi.arn
}

output "finops_sns_topic_arn" {
  description = "ARN do SNS Topic para alertas FinOps"
  value       = aws_sns_topic.finops_alerts.arn
}

output "kubectl_config_command" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}
