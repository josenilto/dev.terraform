# FinOps — EKS Nuvem Privada AWS

Guia de práticas, controles e otimizações de custo para o cluster EKS privado provisionado neste módulo Terraform.

---

## Arquitetura de Referência

```
On-premises network                Amazon Web Services
┌──────────────┐                   ┌─────────────────────────────────────────────┐
│              │                   │  VPC — Amazon EKS (Control Plane)           │
│   Clients    │◄──── Internet ───►│  ┌──────────────────────────────────────┐   │
│  (on-prem)   │                   │  │  EKS Control Plane  (API Server)     │   │
└──────────────┘                   │  └──────────────────────────────────────┘   │
                                   └─────────────────────────────────────────────┘
        │                                              │
        │                          ┌────────────────────────────────────────────────┐
        └──── Internet ───────────►│  VPC — Workers (us-east-1)                     │
                                   │  ┌─────────────┐ ┌─────────────┐ ┌──────────┐ │
                                   │  │ AZ us-east- │ │ AZ us-east- │ │ AZ us-   │ │
                                   │  │ 1a / Subnet │ │ 1b / Subnet │ │ east-1c  │ │
                                   │  │             │ │             │ │ / Subnet │ │
                                   │  │ EC2 Managed │ │ EC2 Self-   │ │ Fargate  │ │
                                   │  │  (Spot)     │ │  Managed    │ │  Pods    │ │
                                   │  │             │ │ (On-demand  │ │          │ │
                                   │  │             │ │  + Spot)    │ │          │ │
                                   │  └─────────────┘ └─────────────┘ └──────────┘ │
                                   └────────────────────────────────────────────────┘
                                                                │
                                   ┌────────────────────────────┐
                                   │  VPC — ECR (Repositórios)  │
                                   │  ┌──────────────────────┐  │
                                   │  │  ECR (imagens Docker)│  │
                                   │  └──────────────────────┘  │
                                   └────────────────────────────┘
```

---

## Estratégias FinOps Implementadas

### 1. Spot Instances — Redução de Custo de Computação

| Node Group | Tipo de Capacidade | Saving Estimado |
|---|---|---|
| EC2 Managed | Spot (`t3.medium`, `t3.large`) | até **70%** vs On-Demand |
| EC2 Self-managed | Spot mix + 1 On-Demand base | até **60%** vs On-Demand |
| Fargate | Por vCPU/GB consumido | Sem nós ociosos |

**Configuração aplicada em `node-groups.tf`:**

```hcl
# Node group managed — Spot puro
capacity_type  = "SPOT"
instance_types = ["t3.medium", "t3.large"]

# Self-managed — Spot com 1 nó On-Demand de base
on_demand_base_capacity                  = 1
on_demand_percentage_above_base_capacity = 0
spot_allocation_strategy                 = "price-capacity-optimized"
```

---

### 2. Cluster Autoscaler — Escala Horizontal Sob Demanda

O Cluster Autoscaler escala os node groups automaticamente, evitando capacidade ociosa.

```
Carga alta  →  Scale-out (adiciona nós até max_size)
Carga baixa →  Scale-in  (remove nós até min_size)
```

| Parâmetro | Managed | Self-managed |
|---|---|---|
| `min_size` | 1 | 1 |
| `desired_size` | 2 | 2 |
| `max_size` | 5 | 4 |

A IAM Role do Cluster Autoscaler usa **IRSA** (IAM Roles for Service Accounts) para acesso com privilégio mínimo.

---

### 3. Fargate — Pay-per-Pod (Sem Nós Ociosos)

Workloads no Fargate são cobrados apenas pelo que consomem (vCPU + memória por segundo).  
Adequado para:
- Tarefas batch e jobs esporádicos
- Namespace `kube-system` (coredns, etc.)
- Ambientes de desenvolvimento/teste com uso intermitente

```hcl
fargate_namespaces = ["kube-system", "fargate-workloads"]
```

---

### 4. NAT Gateway Único — Redução de Custo de Rede

Um único NAT Gateway centralizado substitui o modelo de um NAT por AZ.

| Modelo | Custo/hora | Observação |
|---|---|---|
| 3 NAT Gateways (1/AZ) | ~$0,135/h | Alta disponibilidade |
| 1 NAT Gateway (este módulo) | ~$0,045/h | **FinOps: -66%** |

> Para produção com SLA crítico, avaliar o custo de HA vs. o risco de indisponibilidade do NAT.

---

### 5. VPC Endpoints — Tráfego ECR sem custo de NAT

Os VPC Endpoints permitem que os nós baixem imagens do ECR sem passar pelo NAT Gateway, eliminando o custo de processamento de dados do NAT.

| Endpoint | Tipo | Benefício |
|---|---|---|
| `ecr.api` | Interface | Pull de metadados sem NAT |
| `ecr.dkr` | Interface | Pull de camadas de imagem sem NAT |
| `s3` | Gateway | Layers ECR armazenadas em S3 — gratuito |

Custo estimado dos VPC Endpoints Interface: ~$0,01/hora cada.  
Break-even: ~10 GB/mês de pull de imagens já compensa o custo dos endpoints.

---

### 6. ECR Lifecycle Policy — Controle de Armazenamento

```hcl
ecr_image_retention_count = 30  # máx. 30 imagens por repositório
```

| Regra | Critério | Ação |
|---|---|---|
| Retenção por contagem | mais de 30 imagens | Expirar imagens antigas |
| Imagens não-tagueadas | > 7 dias | Expirar automaticamente |

Custo de armazenamento ECR: $0,10/GB/mês. Com lifecycle policy, evita acumulação ilimitada.

---

### 7. EBS gp3 — Armazenamento 20% mais Barato que gp2

Os discos dos nós self-managed usam `gp3` com IOPS e throughput configurados explicitamente:

```hcl
volume_type = "gp3"
iops        = 3000
throughput  = 125
```

| Tipo | Preço/GB | IOPS base |
|---|---|---|
| `gp2` | $0,10/GB | 3 IOPS/GB (variável) |
| `gp3` | $0,08/GB | 3.000 fixos | 

**Economia: ~20% no custo de storage.**

---

### 8. Scheduled Scaling — Desligar Nós Fora do Horário (dev/staging)

Para ambientes não-produtivos, os nós são desligados fora do horário comercial:

```
Scale-down: 22:00 BRT (Mon-Fri)  →  desired = 0
Scale-up:   07:00 BRT (Mon-Fri)  →  desired = valor original
```

Economia estimada: **~57% do custo de compute** em ambientes dev/staging  
(14h/dia × 5 dias = 70h rodando vs 168h possíveis)

> Controlado pela variável `environment`: só ativado quando `environment != "prod"`.

---

### 9. Orçamento e Alertas — AWS Budgets + Cost Anomaly Detection

#### AWS Budget

| Parâmetro | Valor |
|---|---|
| Limite mensal | `monthly_budget_limit` (USD) |
| Alerta — Custo real | `budget_alert_threshold_pct`% do limite |
| Alerta — Previsão | 100% do limite |
| Destinatários | `budget_alert_emails` |

#### Cost Anomaly Detection

Detecta desvios de gasto acima de **20%** em relação ao padrão histórico e envia alerta diário por e-mail.

#### CloudWatch Dashboard

Dashboard `{project_name}-finops` com painéis de:
- Custo estimado total (USD)
- Utilização de CPU dos nós
- Bytes processados pelo NAT Gateway
- Pull count do ECR

---

### 10. Cost Allocation Tags — Visibilidade por Centro de Custo

Tags ativas no Cost Explorer para segmentação de custos:

| Tag | Valor de Exemplo |
|---|---|
| `Project` | `eks-nuvem-privada` |
| `Environment` | `prod` / `staging` / `dev` |
| `CostCenter` | `CC-1001` |
| `Team` | `platform-engineering` |
| `ManagedBy` | `Terraform` |

Todos os recursos criados herdam essas tags via `default_tags` no provider AWS.

---

## Checklist FinOps — Pré-Deploy

- [ ] Confirmar `monthly_budget_limit` com o time financeiro
- [ ] Validar `budget_alert_emails` com as partes responsáveis
- [ ] Revisar `ecr_image_retention_count` com o time de desenvolvimento
- [ ] Confirmar se o ambiente é `prod` (scheduled scaling desabilitado) ou `dev/staging`
- [ ] Verificar se os tipos de instância Spot têm boa disponibilidade na região (`aws ec2 describe-spot-price-history`)
- [ ] Ativar AWS Compute Optimizer na conta para recomendações de rightsizing

---

## Checklist FinOps — Pós-Deploy (Semana 1-4)

- [ ] Validar alertas de budget chegando nos e-mails configurados
- [ ] Acessar o Cost Explorer e confirmar que as tags estão sendo capturadas
- [ ] Verificar o dashboard CloudWatch `{project_name}-finops`
- [ ] Analisar relatório do Compute Optimizer após 14 dias de uso
- [ ] Avaliar compra de **Savings Plans** após 30 dias de baseline (recomendação AWS: Compute Savings Plans)
- [ ] Revisar logs de VPC Flow Logs para identificar tráfego inesperado (impacto no NAT Gateway)

---

## Estimativa de Custo Mensal (Referência)

> Valores aproximados para `us-east-1`. Consulte a [AWS Pricing Calculator](https://calculator.aws) para valores exatos.

| Recurso | Qtd | Custo Estimado/mês |
|---|---|---|
| EKS Control Plane | 1 cluster | ~$73 |
| EC2 Spot (t3.medium) — Managed | 2 nós | ~$20 |
| EC2 On-Demand+Spot (m5.large) — Self-managed | 2 nós | ~$65 |
| NAT Gateway (1 unidade) | 1 | ~$32 + dados |
| VPC Endpoints Interface (ECR) | 2 | ~$15 |
| ECR Storage (30 imagens × 3 repos) | estimado 15 GB | ~$1,5 |
| EBS gp3 (50 GB × 2 nós) | 100 GB | ~$8 |
| CloudWatch Logs (7-30 dias) | estimado | ~$5 |
| **Total Estimado** | | **~$220–$280/mês** |

> Com Savings Plans de 1 ano (no-upfront), redução adicional de **~20-30%** sobre os recursos On-Demand.

---

## Referências

- [AWS EKS Best Practices — Cost Optimization](https://aws.github.io/aws-eks-best-practices/cost_optimization/cfm_framework/)
- [AWS FinOps Framework](https://www.finops.org/framework/)
- [Spot Instances para EKS](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html)
- [AWS Compute Optimizer](https://aws.amazon.com/compute-optimizer/)
- [Cluster Autoscaler para EKS](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md)
- [ECR Lifecycle Policies](https://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html)
