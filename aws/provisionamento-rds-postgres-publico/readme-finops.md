# FinOps & Padrão de Nomenclatura — RDS PostgreSQL Público

> **Módulo:** `provisionamento-rds-postgres-publico`
> **Provider:** AWS RDS (Relational Database Service) — PostgreSQL com acesso público
> **Arquitetura:** Master (Read/Write) + Read Replica (Read-Only) em AZs distintas
> **Região de referência:** us-east-1 (N. Virginia)

---

## Índice

- [Arquitetura](#-arquitetura)
- [Padrão de Nomenclatura](#-padrão-de-nomenclatura)
- [Estimativa de Custo Mensal](#-estimativa-de-custo-mensal)
- [Variáveis de Estimativa](#-variáveis-de-estimativa)
- [Controle de Orçamento — Budget Alerts](#-controle-de-orçamento--budget-alerts)
- [Outputs FinOps](#-outputs-finops)
- [Cenários de Custo](#-cenários-de-custo)
- [Otimização de Custos](#-otimização-de-custos)

---

## Arquitetura

```
                        Usuário / Aplicação
                               │
                    ┌──────────┴──────────┐
               Read/Write             Read-Only
                    │                     │
          ┌─────────▼─────────────────────▼──────────┐
          │                    VPC                    │
          │   ┌────────────────────────────────────┐  │
          │   │        VPC Security Group          │  │
          │   │  (porta 5432 — PostgreSQL)         │  │
          │   │                                    │  │
          │   │  ┌──────────────┐  ┌────────────┐ │  │
          │   │  │  Subnet A    │  │  Subnet B  │ │  │
          │   │  │  AZ 1        │  │  AZ 2      │ │  │
          │   │  │              │  │            │ │  │
          │   │  │  RDS Master  │──│ Read       │ │  │
          │   │  │  (M)         │  │ Replica(R) │ │  │
          │   │  │              │  │            │ │  │
          │   │  └──────────────┘  └────────────┘ │  │
          │   │     Replicação ──────────►         │  │
          │   └────────────────────────────────────┘  │
          └───────────────────────────────────────────┘
                              Region
```

### Componentes Provisionados

| Recurso | Arquivo | Descrição |
|---|---|---|
| `aws_vpc` | [vpc.tf](vpc.tf) | VPC isolada com DNS habilitado |
| `aws_subnet` (A) | [vpc.tf](vpc.tf) | Subnet pública — AZ1 — RDS Master |
| `aws_subnet` (B) | [vpc.tf](vpc.tf) | Subnet pública — AZ2 — Read Replica |
| `aws_internet_gateway` | [vpc.tf](vpc.tf) | Gateway para acesso público |
| `aws_route_table` | [vpc.tf](vpc.tf) | Rota padrão via IGW |
| `aws_security_group` | [vpc.tf](vpc.tf) | Libera porta 5432 — PostgreSQL |
| `aws_db_subnet_group` | [vpc.tf](vpc.tf) | Agrupa Subnet A e B para o RDS |
| `aws_db_parameter_group` | [rds.tf](rds.tf) | Parameter group PostgreSQL |
| `aws_db_instance` (master) | [rds.tf](rds.tf) | RDS Master — Read/Write — AZ1 |
| `aws_db_instance` (replica) | [rds.tf](rds.tf) | RDS Read Replica — Read-Only — AZ2 |
| `aws_budgets_budget` | [finops.tf](finops.tf) | Alertas de orçamento mensal |

---

## Padrão de Nomenclatura

### Formato

```
{project_abbrev}-{env_abbrev}-pgpub-{random_6chars}
```

| Segmento | Origem | Regras | Exemplo |
|---|---|---|---|
| `{project_abbrev}` | `var.project_abbrev` | 1–12 chars, apenas `[a-z0-9]` | `finance` |
| `{env_abbrev}` | `var.environment` → local | mapeado automaticamente | `dev` |
| `pgpub` | fixo | identifica tipo (PostgreSQL) e visibilidade (público) | `pgpub` |
| `{random_6chars}` | `random_string` | 6 chars, `[a-z0-9]`, imutável após apply | `8k2m9z` |

### Mapeamento de Ambientes

| `var.environment` | Abreviação gerada |
|---|---|
| `development` | `dev` |
| `staging` | `stg` |
| `production` | `prd` |

### Exemplos de Nomes Gerados

```
project_abbrev = "finance"  +  environment = "development"  →  finance-dev-pgpub-8k2m9z
project_abbrev = "api"      +  environment = "staging"      →  api-stg-pgpub-3x7q1r
project_abbrev = "payments" +  environment = "production"   →  payments-prd-pgpub-9p4k2m
```

### Recursos derivados do prefixo base

| Recurso | Identifier gerado |
|---|---|
| RDS Master | `{prefix}` |
| RDS Read Replica | `{prefix}-replica` |
| VPC | `{prefix}-vpc` |
| Subnet A | `{prefix}-subnet-a` |
| Subnet B | `{prefix}-subnet-b` |
| Internet Gateway | `{prefix}-igw` |
| Security Group | `{prefix}-sg` |
| DB Subnet Group | `{prefix}-subnetgrp` |
| Parameter Group | `{prefix}-pg` |
| Budget | `budget-{prefix}-mensal` |

### Regras AWS RDS — DB Identifier

```
✅  Apenas letras minúsculas, números e hífens
✅  Entre 1 e 63 caracteres
✅  Deve começar com uma letra
❌  Sem underscores, maiúsculas ou caracteres especiais
❌  Não pode começar ou terminar com hífen
❌  Não pode ter dois hífens consecutivos
```

### Onde está definido

| Arquivo | Responsabilidade |
|---|---|
| [random.tf](random.tf) | Gera o sufixo aleatório de 6 chars via `random_string` |
| [locals.tf](locals.tf) | Compõe `local.name_prefix`, `local.db_identifier` e `local.db_replica_identifier` |
| [variables.tf](variables.tf) | Declara `project_abbrev` e `environment` com validações |
| [terraform.tfvars](terraform.tfvars) | Define os valores do projeto/ambiente |

> **Importante:** o sufixo aleatório é gerado apenas uma vez no `terraform apply` inicial e fica registrado no `terraform.tfstate`. Ele não muda em re-applies subsequentes, garantindo estabilidade nos identifiers do RDS.

---

## Estimativa de Custo Mensal

> Preços de referência: [AWS Pricing — RDS PostgreSQL](https://aws.amazon.com/rds/postgresql/pricing)
> Região: **us-east-1 (N. Virginia)** | Moeda: **USD** | Base de cálculo: **720 horas/mês**

### Composição do Custo

```
┌──────────────────────────────────────────────────────────────────────────────┐
│           CUSTO MENSAL ESTIMADO — RDS PostgreSQL Público (Master + Replica)  │
├──────────────────────────────────────┬──────────────────┬────────────────────┤
│ Componente                           │ Preço Unit.      │ Estimativa Mensal  │
├──────────────────────────────────────┼──────────────────┼────────────────────┤
│ RDS Master — db.t3.micro (720h)      │ $0.017/hora      │ $12.24             │
│ Read Replica — db.t3.micro (720h)    │ $0.017/hora      │ $12.24             │
│ Storage Master — GP2 (20 GB)         │ $0.115/GB/mês    │ $2.30              │
│ Storage Replica — GP2 (20 GB)        │ $0.115/GB/mês    │ $2.30              │
│ Backup Storage (20 GB além free)     │ $0.095/GB/mês    │ $1.90              │
│ Egress — saída de dados (10 GB)      │ $0.09/GB         │ $0.90              │
│ Transfer IN (entrada)                │ Gratuito         │ $0.00              │
├──────────────────────────────────────┼──────────────────┼────────────────────┤
│ TOTAL MENSAL ESTIMADO                │                  │ ~ $31.88           │
│ TOTAL ANUAL ESTIMADO                 │                  │ ~ $382.56          │
└──────────────────────────────────────┴──────────────────┴────────────────────┘

Premissas: db.t3.micro x2, 20 GB storage GP2 cada, 20 GB backup, 10 GB egress/mês
```

### Preços por Classe de Instância (us-east-1, On-Demand)

| Classe | vCPU | RAM | Preço/hora | Preço/mês (720h) | Custo Master+Replica/mês |
|---|---|---|---|---|---|
| `db.t3.micro` | 2 | 1 GB | $0.017 | $12.24 | **$24.48** |
| `db.t3.small` | 2 | 2 GB | $0.034 | $24.48 | **$48.96** |
| `db.t3.medium` | 2 | 4 GB | $0.068 | $48.96 | **$97.92** |
| `db.t3.large` | 2 | 8 GB | $0.136 | $97.92 | **$195.84** |
| `db.r6g.large` | 2 | 16 GB | $0.192 | $138.24 | **$276.48** |
| `db.r6g.xlarge` | 4 | 32 GB | $0.384 | $276.48 | **$552.96** |

> Para alterar a classe, ajuste `db_instance_class` e `estimated_instance_hourly_price_usd` no `terraform.tfvars`.

### Detalhamento dos Componentes

#### Instâncias RDS (Master + Read Replica) — $0.017/hora cada

Cada instância é cobrada separadamente. Com a arquitetura Master + Replica, você paga por **duas instâncias**.

```
custo_instancia = preco_hora × 720 horas
custo_total_instancias = custo_master + custo_replica
```

| Classe | Custo 1 instância/mês | Custo Master+Replica/mês |
|---|---|---|
| db.t3.micro | $12.24 | $24.48 |
| db.t3.small | $24.48 | $48.96 |
| db.t3.medium | $48.96 | $97.92 |

#### Storage GP2 — $0.115/GB/mês por instância

Cobrado por GB alocado em **cada** instância. A Read Replica tem seu próprio volume de storage.

```
custo_storage = storage_gb × $0.115 × 2 instâncias
```

| Storage por instância | Custo Master/mês | Custo Replica/mês | Total/mês |
|---|---|---|---|
| 20 GB | $2.30 | $2.30 | $4.60 |
| 50 GB | $5.75 | $5.75 | $11.50 |
| 100 GB | $11.50 | $11.50 | $23.00 |
| 500 GB | $57.50 | $57.50 | $115.00 |

> O `max_allocated_storage` habilita autoscaling de storage — aumente automaticamente até o limite configurado sem downtime. O custo cresce proporcionalmente ao volume real alocado.

#### Backup Storage — $0.095/GB/mês

O free tier de backup equivale ao tamanho do banco de dados. Armazenamento de backup **além** desse limite é cobrado.

```
free_tier_backup = storage_alocado_gb
custo_backup = (backup_total_gb - free_tier_backup) × $0.095
```

| Backup storage acima do free | Custo/mês |
|---|---|
| 0 GB (sem excedente) | $0.00 |
| 20 GB | $1.90 |
| 50 GB | $4.75 |
| 100 GB | $9.50 |

> Retention de 7 dias com DB de 20 GB pode gerar até ~140 GB de backups brutos, mas a AWS comprime incrementalmente — o custo real costuma ser menor.

#### Egress (saída de dados) — $0.09/GB

Transferência de dados do RDS para a internet (ex.: aplicação fora da AWS, ferramentas de BI externas).

```
custo_egress = egress_gb × $0.09
```

| Egress/mês | Custo mensal |
|---|---|
| 10 GB | $0.90 |
| 100 GB | $9.00 |
| 1 TB | $92.16 |

> Tráfego entre RDS e EC2/Lambda/ECS **na mesma VPC e região** não gera custo de egress.

#### Transfer IN — gratuito

Dados enviados para o RDS (INSERTs, UPDATEs, imports) não são cobrados.

---

## Variáveis de Estimativa

Ajuste no [terraform.tfvars](terraform.tfvars) para refletir o uso real do projeto:

```hcl
# FinOps — estimativas mensais de uso
estimated_instance_hourly_price_usd = 0.017   # db.t3.micro us-east-1
estimated_storage_gb                = 20       # GB por instância (Master e Replica)
estimated_backup_storage_gb         = 20       # GB de backup além do free tier
estimated_egress_gb_per_month       = 10       # GB de saída para internet
```

| Variável | Tipo | Padrão | Impacto no custo |
|---|---|---|---|
| `estimated_instance_hourly_price_usd` | `number` | `0.017` | $×720h por instância; aplicado ao Master e Replica |
| `estimated_storage_gb` | `number` | `20` | $0.115 por GB/mês por instância (×2) |
| `estimated_backup_storage_gb` | `number` | `20` | $0.095 por GB/mês de backup excedente |
| `estimated_egress_gb_per_month` | `number` | `10` | $0.09 por GB de saída |

---

## Controle de Orçamento — Budget Alerts

O recurso `aws_budgets_budget` monitora o custo mensal associado à conta AWS e dispara alertas por e-mail em três níveis progressivos.

### Fluxo de alertas

```
Custo mensal acumulado
        │
        ├── > 80% do budget ($64,00)  →  ⚠️  Alerta preventivo       → e-mail
        │
        ├── > 100% do budget ($80,00) →  🚨  Limite atingido          → e-mail
        │
        └── > 110% projetado ($88,00) →  📊  Forecast acima do limite → e-mail
```

### Configuração atual (`terraform.tfvars`)

```hcl
budget_amount_monthly = 80
budget_contact_emails = ["josenilto@outlook.com"]
```

### Detalhamento dos alertas

| # | Threshold | Tipo | Trigger | Valor de referência |
|---|---|---|---|---|
| 1 | 80% | `ACTUAL` | Custo real acumulado | $64,00 |
| 2 | 100% | `ACTUAL` | Custo real acumulado | $80,00 |
| 3 | 110% | `FORECASTED` | Projeção até fim do mês | $88,00 |

> O alerta `FORECASTED` é disparado quando o AWS projeta que o custo final do mês ultrapassará 110% do budget, mesmo que o custo atual ainda esteja abaixo do limite.

---

## Outputs FinOps

Após `terraform apply`, consulte os outputs de custo:

```bash
# Custo mensal total
terraform output finops_monthly_total_usd

# Custo anual total
terraform output finops_annual_total_usd

# Breakdown por componente
terraform output finops_cost_breakdown

# Resumo completo com premissas
terraform output finops_summary

# Informações do budget
terraform output finops_budget_name
terraform output finops_budget_amount_usd
```

### Exemplo de saída esperada

```hcl
finops_cost_breakdown = {
  master_instance_usd  = "$12.24"
  replica_instance_usd = "$12.24"
  master_storage_usd   = "$2.30"
  replica_storage_usd  = "$2.30"
  backup_storage_usd   = "$1.90"
  egress_usd           = "$0.90"
}

finops_monthly_total_usd = "$31.88"
finops_annual_total_usd  = "$382.56"

finops_summary = {
  annual_cost_usd        = "$382.56"
  db_identifier          = "myproject-dev-pgpub-8k2m9z"
  replica_identifier     = "myproject-dev-pgpub-8k2m9z-replica"
  egress_gb_month        = 10
  engine_version         = "16.1"
  instance_class         = "db.t3.micro"
  instance_hourly_price  = "$0.0170"
  monthly_cost_usd       = "$31.88"
  pricing_reference      = "https://aws.amazon.com/rds/postgresql/pricing"
  region                 = "us-east-1"
  storage_gb             = 20
}
```

### Endpoints de conexão (outputs de infraestrutura)

```bash
# Endpoint do Master (Read/Write)
terraform output master_endpoint
# → "myproject-dev-pgpub-8k2m9z.xxxx.us-east-1.rds.amazonaws.com:5432"

# Endpoint da Read Replica (Read-Only)
terraform output replica_endpoint
# → "myproject-dev-pgpub-8k2m9z-replica.xxxx.us-east-1.rds.amazonaws.com:5432"

# String de conexão — Master
terraform output connection_string_master
# → "postgresql://dbadmin:***@myproject-dev-pgpub-8k2m9z.xxxx.us-east-1.rds.amazonaws.com:5432/appdb"

# String de conexão — Replica
terraform output connection_string_replica
# → "postgresql://dbadmin:***@myproject-dev-pgpub-8k2m9z-replica.xxxx.us-east-1.rds.amazonaws.com:5432/appdb"
```

---

## Cenários de Custo

| Cenário | Instância | Storage | Backup excedente | Egress | Custo mensal |
|---|---|---|---|---|---|
| Dev mínimo | db.t3.micro ×2 | 20 GB ×2 | 0 GB | 1 GB | **~$29.07** |
| Dev ativo | db.t3.micro ×2 | 20 GB ×2 | 20 GB | 10 GB | **~$31.88** |
| Staging | db.t3.small ×2 | 50 GB ×2 | 50 GB | 50 GB | **~$74.21** |
| Produção leve | db.t3.medium ×2 | 100 GB ×2 | 100 GB | 100 GB | **~$142.00** |
| Produção média | db.r6g.large ×2 | 500 GB ×2 | 200 GB | 500 GB | **~$548.00** |
| Produção alta | db.r6g.xlarge ×2 | 1 TB ×2 | 500 GB | 1 TB | **~$1.280.00** |

> Os custos de instância dominam em ambientes menores. Em produção com volume alto, storage e egress passam a ser drivers relevantes.

---

## Otimização de Custos

```
💡  Direcione leituras para a Read Replica — alivie o Master e
    aproveite o custo já pago pela instância de réplica. Configure
    sua aplicação ou ORM com dois connection pools (writer/reader).

💡  Use Reserved Instances para cargas previsíveis em produção.
    1 ano (No Upfront) no db.t3.micro economiza ~30% vs On-Demand.
    3 anos (All Upfront) pode chegar a ~60% de desconto.

💡  Habilite storage autoscaling (max_allocated_storage > 0) em vez
    de pré-alocar armazenamento excedente. Você paga apenas pelo que
    realmente usa, e evita o custo de over-provisioning.

💡  Em dev/staging, considere desligar o RDS fora do horário comercial
    com AWS EventBridge + Lambda ou RDS Scheduler. Uma instância ligada
    apenas 8h/dia custa ~1/3 do preço mensal de uptime contínuo.

💡  Evite egress desnecessário: mantenha sua aplicação na mesma VPC
    e região que o RDS. Tráfego intra-VPC não é cobrado — apenas
    saídas para internet e cross-region geram custo de transfer.

💡  Monitore slow queries com Performance Insights (incluso no Free
    Tier para instâncias elegíveis) para identificar queries caras
    antes que elas forcem um upgrade de classe de instância.

💡  Para workloads de leitura intensiva, avalie Amazon Aurora
    PostgreSQL Serverless v2 — escala automaticamente e pode ser mais
    barato que manter réplicas fixas em cargas variáveis.
```

---

> Preços sujeitos a alteração. Consulte sempre a [calculadora oficial da AWS](https://calculator.aws) para estimativas atualizadas antes de decisões orçamentárias.

<p align="center">
  <sub>Gerenciado por Terraform · FinOps RDS PostgreSQL Público · Atualizado em Jun/2026</sub>
</p>
