# FinOps & Padrão de Nomenclatura — ACR Privado

> **Módulo:** `provisionamento-acr-privado`
> **Provider:** Azure Container Registry (Premium) + Private Endpoint
> **Região de referência:** East US

---

## Índice

- [Padrão de Nomenclatura](#-padrão-de-nomenclatura)
- [Estimativa de Custo Mensal](#-estimativa-de-custo-mensal)
- [Variáveis de Estimativa](#-variáveis-de-estimativa)
- [Outputs FinOps](#-outputs-finops)
- [Cenários de Custo](#-cenários-de-custo)
- [Otimização de Custos](#-otimização-de-custos)

---

## Padrão de Nomenclatura

### Formato

```
acr{project_abbrev}{env_abbrev}{random_6chars}
```

| Segmento | Origem | Regras | Exemplo |
|---|---|---|---|
| `acr` | fixo | prefixo obrigatório do tipo de recurso | `acr` |
| `{project_abbrev}` | `var.project_abbrev` | 1–10 chars, apenas `[a-z0-9]` | `finance` |
| `{env_abbrev}` | `var.environment` → local | mapeado automaticamente | `dev` |
| `{random_6chars}` | `random_string` | 6 chars, `[a-z0-9]`, imutável após apply | `8k2m9z` |

### Mapeamento de Ambientes

| `var.environment` | Abreviação gerada |
|---|---|
| `development` | `dev` |
| `staging` | `stg` |
| `production` | `prd` |

### Exemplos de Nomes Gerados

```
project_abbrev = "finance"  +  environment = "development"  →  acrfinancedev8k2m9z
project_abbrev = "api"      +  environment = "staging"      →  acrapistrg3x7q1r
project_abbrev = "payments" +  environment = "production"   →  acrpaymentsprd9p4k2m
```

### Regras Azure ACR

```
✅  Apenas letras e números  [a-zA-Z0-9]
✅  Entre 5 e 50 caracteres
✅  Globalmente único no Azure
❌  Sem hífens, underscores ou caracteres especiais
```

### Onde está definido

| Arquivo | Responsabilidade |
|---|---|
| [`random.tf`](random.tf) | Gera o sufixo aleatório de 6 chars via `random_string` |
| [`locals.tf`](locals.tf) | Compõe `local.acr_name` a partir dos segmentos |
| [`variables.tf`](variables.tf) | Declara `project_abbrev` e `environment` com validações |
| [`terraform.tfvars`](terraform.tfvars) | Define os valores do projeto/ambiente |

> **Importante:** o sufixo aleatório é gerado apenas uma vez no `terraform apply` inicial e fica registrado no `terraform.tfstate`. Ele não muda em re-applies subsequentes, garantindo estabilidade no nome do recurso.

---

## Estimativa de Custo Mensal

> Preços de referência: [Azure Pricing — Container Registry](https://azure.microsoft.com/pricing/details/container-registry)
> Região: **East US** | Moeda: **USD** | Base de cálculo: **30 dias/mês**

### Composição do Custo

```
┌─────────────────────────────────────────────────────────────────────┐
│              CUSTO MENSAL ESTIMADO — ACR PRIVADO (PREMIUM)          │
├─────────────────────────────┬──────────────┬────────────────────────┤
│ Componente                  │ Preço Unit.  │ Estimativa Mensal      │
├─────────────────────────────┼──────────────┼────────────────────────┤
│ Registry Premium            │ $0.667/dia   │ $20.01                 │
│ Storage extra (> 500 GiB)   │ $0.0034/GiB  │ $0.00 *               │
│ ACR Build Tasks             │ $0.006/min   │ $0.00 **              │
│ Private DNS Zone            │ $0.50/zona   │ $0.50                  │
│ DNS Queries                 │ $0.40/milhão │ $0.40                  │
│ Egress de dados             │ $0.087/GB    │ $0.87                  │
├─────────────────────────────┼──────────────┼────────────────────────┤
│ TOTAL MENSAL ESTIMADO       │              │ ~ $21.78               │
│ TOTAL ANUAL ESTIMADO        │              │ ~ $261.36              │
└─────────────────────────────┴──────────────┴────────────────────────┘

*  50 GB estimados — 500 GB já incluídos no SKU Premium (sem custo extra)
** Sem builds estimados no ambiente de referência
```

### Detalhamento dos Componentes

#### Registry Premium — $20.01/mês
Taxa base do SKU Premium cobrada por dia de existência do recurso, independente do uso.
Inclui: 500 GiB de armazenamento, webhooks ilimitados, geo-replicação (por localização adicional).

#### Storage Extra — $0.00/mês (baseline)
O SKU Premium inclui **500 GiB**. Custo adicional só incide acima desse limite.

```
storage_extra_gb = max(0, estimated_storage_gb - 500)
custo_storage    = storage_extra_gb × $0.0034/GiB/dia × 30 dias
```

| Armazenamento total | Extra cobrado | Custo mensal |
|---|---|---|
| 50 GB | 0 GB | $0.00 |
| 500 GB | 0 GB | $0.00 |
| 600 GB | 100 GB | ~$10.20 |
| 1000 GB | 500 GB | ~$51.00 |

#### ACR Build Tasks — variável
Execução de builds de imagem dentro do próprio ACR (substitui um CI externo).

```
custo_build = minutos_por_mes × $0.006/minuto
```

| Minutos/mês | Custo mensal |
|---|---|
| 0 | $0.00 |
| 100 | $0.60 |
| 500 | $3.00 |
| 1000 | $6.00 |

#### Private DNS Zone — $0.50/mês
Uma zona `privatelink.azurecr.io` por módulo. Custo fixo por zona provisionada.

#### DNS Queries — $0.40/milhão
Consultas DNS resolvidas pela zona privada (cada pull/push de imagem gera consultas).

| Consultas/mês | Custo mensal |
|---|---|
| 1 M | $0.40 |
| 5 M | $2.00 |
| 10 M | $4.00 |

#### Egress — $0.087/GB
Transferência de dados do ACR para fora da região Azure (ex.: pulls de outras regiões).
Tráfego dentro da mesma região/VNet não é cobrado.

---

## Variáveis de Estimativa

Ajuste no [`terraform.tfvars`](terraform.tfvars) para refletir o uso real do projeto:

```hcl
# FinOps — estimativas mensais de uso
estimated_storage_gb                   = 50    # GB de imagens armazenadas
estimated_build_minutes_per_month      = 0     # minutos de ACR Tasks
estimated_monthly_dns_queries_millions = 1     # milhões de queries DNS
estimated_egress_gb_per_month          = 10    # GB de saída de dados
```

| Variável | Tipo | Padrão | Impacto no custo |
|---|---|---|---|
| `estimated_storage_gb` | `number` | `50` | Extra acima de 500 GB |
| `estimated_build_minutes_per_month` | `number` | `0` | $0.006 por minuto |
| `estimated_monthly_dns_queries_millions` | `number` | `1` | $0.40 por milhão |
| `estimated_egress_gb_per_month` | `number` | `10` | $0.087 por GB |

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
```

### Exemplo de saída esperada

```hcl
finops_cost_breakdown = {
  acr_registry_premium_usd = "$20.01"
  build_tasks_usd          = "$0.00"
  dns_queries_usd          = "$0.40"
  egress_usd               = "$0.87"
  private_dns_zone_usd     = "$0.50"
  storage_extra_usd        = "$0.00"
}

finops_monthly_total_usd = "$21.78"
finops_annual_total_usd  = "$261.36"

finops_summary = {
  acr_name             = "acrfinancedev8k2m9z"
  annual_cost_usd      = "$261.36"
  build_minutes_month  = 0
  dns_queries_millions = 1
  egress_gb_month      = 10
  estimated_storage_gb = 50
  monthly_cost_usd     = "$21.78"
  pricing_reference    = "https://azure.microsoft.com/pricing/details/container-registry"
  region               = "East US"
  sku                  = "Premium"
  storage_extra_gb     = 0
  storage_included_gb  = 500
}
```

---

## Cenários de Custo

| Cenário | Storage | Builds/mês | Egress | Custo mensal |
|---|---|---|---|---|
| Dev mínimo | 50 GB | 0 min | 5 GB | **~$21.35** |
| Dev ativo | 100 GB | 100 min | 10 GB | **~$22.47** |
| Staging | 200 GB | 300 min | 20 GB | **~$25.14** |
| Produção leve | 300 GB | 500 min | 50 GB | **~$29.40** |
| Produção intensa | 600 GB | 1000 min | 100 GB | **~$46.59** |

> Nota: Storage abaixo de 500 GB não gera custo extra. O custo base do Premium ($20.01) é fixo em todos os cenários.

---

## Otimização de Custos

```
💡  Use ACR Tasks apenas para builds leves — prefira CI/CD externo (GitHub Actions,
    Azure DevOps) para pipelines complexos, evitando cobranças por minuto de build.

💡  Mantenha imagens sem tag por no máximo 7 dias (retention_policy) para evitar
    acúmulo de storage desnecessário.

💡  Pulls de imagem dentro da mesma região Azure não geram custo de egress.
    Configure workloads no mesmo datacenter (East US) para zerar esse custo.

💡  Uma única Private DNS Zone pode ser compartilhada entre múltiplos ACRs dentro
    da mesma VNet — evite criar uma zona por ACR em ambientes com múltiplos registries.

💡  Geo-replicação adiciona ~$20/mês por região extra. Use apenas em produção
    onde a latência de pull impacta deployments globais.
```

---

> Preços sujeitos a alteração. Consulte sempre a [calculadora oficial do Azure](https://azure.microsoft.com/pricing/calculator) para estimativas atualizadas antes de decisões orçamentárias.
