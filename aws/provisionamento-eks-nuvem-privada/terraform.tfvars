aws_region   = "us-east-1"
project_name = "eks-nuvem-privada"
environment  = "prod"
cost_center  = "CC-1001"
owner        = "infra-team@empresa.com"
team         = "platform-engineering"

# VPC
vpc_cidr           = "10.0.0.0/16"
private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# EKS
cluster_name    = "eks-privado"
cluster_version = "1.29"

# Nós Gerenciados (Spot)
managed_node_instance_types = ["t3.medium", "t3.large"]
managed_node_desired        = 2
managed_node_min            = 1
managed_node_max            = 5

# Nós Self-managed (On-demand + Spot mix)
self_managed_node_instance_types = ["m5.large", "m5a.large", "m5n.large"]
self_managed_node_desired        = 2
self_managed_node_min            = 1
self_managed_node_max            = 4

# Fargate
fargate_namespaces = ["kube-system", "fargate-workloads"]

# ECR
ecr_repositories          = ["app-backend", "app-frontend", "app-worker"]
ecr_image_retention_count = 30

# On-premises
onprem_cidr = "192.168.0.0/16"

# FinOps
monthly_budget_limit       = "500"
budget_alert_threshold_pct = 80
budget_alert_emails        = ["finops@empresa.com", "infra-lead@empresa.com"]
