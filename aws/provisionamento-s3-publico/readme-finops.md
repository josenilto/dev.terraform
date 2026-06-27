# FinOps & Padrão de Nomenclatura — S3 Público

> **Módulo:** `provisionamento-s3-publico`
> **Provider:** AWS S3 (Simple Storage Service) — acesso público de leitura
> **Região de referência:** us-east-1 (N. Virginia)

---

## Índice

- [Padrão de Nomenclatura](#-padrão-de-nomenclatura)
- [Estimativa de Custo Mensal](#-estimativa-de-custo-mensal)
- [Variáveis de Estimativa](#-variáveis-de-estimativa)
- [Controle de Orçamento — Budget Alerts](#-controle-de-orçamento--budget-alerts)
- [Outputs FinOps](#-outputs-finops)
- [Cenários de Custo](#-cenários-de-custo)
- [Otimização de Custos](#-otimização-de-custos)

---

## Padrão de Nomenclatura

### Formato

```
{project_abbrev}-{env_abbrev}-s3pub-{random_6chars}
```

| Segmento | Origem | Regras | Exemplo |
|---|---|---|---|
| `{project_abbrev}` | `var.project_abbrev` | 1–12 chars, apenas `[a-z0-9]` | `finance` |
| `{env_abbrev}` | `var.environment` → local | mapeado automaticamente | `dev` |
| `s3pub` | fixo | identifica tipo e visibilidade | `s3pub` |
| `{random_6chars}` | `random_string` | 6 chars, `[a-z0-9]`, imutável após apply | `8k2m9z` |

### Mapeamento de Ambientes

| `var.environment` | Abreviação gerada |
|---|---|
| `development` | `dev` |
| `staging` | `stg` |
| `production` | `prd` |

### Exemplos de Nomes Gerados

```
project_abbrev = "finance"  +  environment = "development"  →  finance-dev-s3pub-8k2m9z
project_abbrev = "api"      +  environment = "staging"      →  api-stg-s3pub-3x7q1r
project_abbrev = "payments" +  environment = "production"   →  payments-prd-s3pub-9p4k2m
```

### Regras AWS S3

```
✅  Apenas letras minúsculas, números e hífens
✅  Entre 3 e 63 caracteres
✅  Globalmente único no AWS (namespace universal)
❌  Sem underscores, maiúsculas ou caracteres especiais
❌  Não pode começar ou terminar com hífen
❌  Não pode ter dois hífens consecutivos
```

### Onde está definido

| Arquivo | Responsabilidade |
|---|---|
| [random.tf](random.tf) | Gera o sufixo aleatório de 6 chars via `random_string` |
| [locals.tf](locals.tf) | Compõe `local.bucket_name` a partir dos segmentos |
| [variables.tf](variables.tf) | Declara `project_abbrev` e `environment` com validações |
| [terraform.tfvars](terraform.tfvars) | Define os valores do projeto/ambiente |

> **Importante:** o sufixo aleatório é gerado apenas uma vez no `terraform apply` inicial e fica registrado no `terraform.tfstate`. Ele não muda em re-applies subsequentes, garantindo estabilidade no nome do bucket.

---

## Estimativa de Custo Mensal

> Preços de referência: [AWS Pricing — S3](https://aws.amazon.com/s3/pricing)
> Região: **us-east-1 (N. Virginia)** | Moeda: **USD** | Base de cálculo: **30 dias/mês**

### Composição do Custo

```
┌─────────────────────────────────────────────────────────────────────┐
│             CUSTO MENSAL ESTIMADO — S3 PÚBLICO (Standard)           │
├──────────────────────────────┬─────────────────┬────────────────────┤
│ Componente                   │ Preço Unit.     │ Estimativa Mensal  │
├──────────────────────────────┼─────────────────┼────────────────────┤
│ Armazenamento (10 GB)        │ $0.023/GB/mês   │ $0.23              │
│ PUT/COPY/POST/LIST (10K req) │ $0.005/1K req   │ $0.05              │
│ GET/SELECT (100K req)        │ $0.0004/1K req  │ $0.04              │
│ Egress — saída de dados      │ $0.09/GB        │ $0.90              │
│ Transfer IN (entrada)        │ Gratuito        │ $0.00              │
├──────────────────────────────┼─────────────────┼────────────────────┤
│ TOTAL MENSAL ESTIMADO        │                 │ ~ $1.22            │
│ TOTAL ANUAL ESTIMADO         │                 │ ~ $14.64           │
└──────────────────────────────┴─────────────────┴────────────────────┘

Premissas: 10 GB armazenados, 10K PUTs, 100K GETs, 10 GB egress/mês
```

### Detalhamento dos Componentes

#### Armazenamento — $0.023/GB/mês

Taxa linear sobre o volume total armazenado no bucket. Não há camadas incluídas no preço base do S3 Standard — todo GB é cobrado.

| Armazenamento | Custo mensal |
|---|---|
| 10 GB | $0.23 |
| 50 GB | $1.15 |
| 100 GB | $2.30 |
| 1 TB | $23.00 |

> Para volumes maiores, considere S3 Intelligent-Tiering ou S3 Standard-IA (dados acessados raramente).

#### PUT/COPY/POST/LIST — $0.005 por 1.000 requisições

Cobrado por cada operação de escrita ou listagem enviada ao bucket. Relevante para pipelines que fazem uploads frequentes.

```
custo_put = (put_requests / 1.000) × $0.005
```

| Requisições/mês | Custo mensal |
|---|---|
| 10K | $0.05 |
| 100K | $0.50 |
| 1M | $5.00 |

#### GET/SELECT — $0.0004 por 1.000 requisições

Cobrado por cada leitura de objeto. Um bucket público com acesso de browser tende a gerar um volume alto de GETs.

```
custo_get = (get_requests / 1.000) × $0.0004
```

| Requisições/mês | Custo mensal |
|---|---|
| 100K | $0.04 |
| 1M | $0.40 |
| 10M | $4.00 |

#### Egress (saída de dados) — $0.09/GB

Transferência de dados do S3 para a internet (ex.: downloads de assets por usuários finais). É o maior driver de custo em buckets públicos com alto tráfego.

```
custo_egress = egress_gb × $0.09
```

| Egress/mês | Custo mensal |
|---|---|
| 10 GB | $0.90 |
| 100 GB | $9.00 |
| 1 TB | $92.16 |

> Tráfego entre S3 e recursos AWS na mesma região (ex.: EC2, CloudFront) não gera custo de egress.

#### Transfer IN — gratuito

Upload de dados para o S3 não é cobrado, independente do volume.

---

## Variáveis de Estimativa

Ajuste no [terraform.tfvars](terraform.tfvars) para refletir o uso real do projeto:

```hcl
# FinOps — estimativas mensais de uso
estimated_storage_gb             = 10    # GB armazenados no bucket
estimated_put_requests_thousands = 10    # milhares de PUT/POST/COPY/LIST
estimated_get_requests_thousands = 100   # milhares de GET/SELECT
estimated_egress_gb_per_month    = 10    # GB de saída para internet
```

| Variável | Tipo | Padrão | Impacto no custo |
|---|---|---|---|
| `estimated_storage_gb` | `number` | `10` | $0.023 por GB/mês |
| `estimated_put_requests_thousands` | `number` | `10` | $0.005 por mil requisições |
| `estimated_get_requests_thousands` | `number` | `100` | $0.0004 por mil requisições |
| `estimated_egress_gb_per_month` | `number` | `10` | $0.09 por GB |

---

## Controle de Orçamento — Budget Alerts

O recurso `aws_budgets_budget` monitora o custo mensal associado à conta AWS e dispara alertas por e-mail em três níveis progressivos.

### Fluxo de alertas

```
Custo mensal acumulado
        │
        ├── > 80% do budget ($16,00)  →  ⚠️  Alerta preventivo      → e-mail
        │
        ├── > 100% do budget ($20,00) →  🚨  Limite atingido         → e-mail
        │
        └── > 110% projetado ($22,00) →  📊  Forecast acima do limite → e-mail
```

### Configuração atual (`terraform.tfvars`)

```hcl
budget_amount_monthly = 20
budget_contact_emails = ["josenilto@outlook.com"]
```

### Detalhamento dos alertas

| # | Threshold | Tipo | Trigger | Valor de referência |
|---|---|---|---|---|
| 1 | 80% | `ACTUAL` | Custo real acumulado | $16,00 |
| 2 | 100% | `ACTUAL` | Custo real acumulado | $20,00 |
| 3 | 110% | `FORECASTED` | Projeção até fim do mês | $22,00 |

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
  storage_usd      = "$0.23"
  put_requests_usd = "$0.05"
  get_requests_usd = "$0.04"
  egress_usd       = "$0.90"
}

finops_monthly_total_usd = "$1.22"
finops_annual_total_usd  = "$14.64"

finops_summary = {
  annual_cost_usd        = "$14.64"
  bucket_name            = "myproject-dev-s3pub-8k2m9z"
  egress_gb_month        = 10
  estimated_storage_gb   = 10
  get_requests_thousands = 100
  monthly_cost_usd       = "$1.22"
  pricing_reference      = "https://aws.amazon.com/s3/pricing"
  put_requests_thousands = 10
  region                 = "us-east-1"
}
```

### Endpoints do bucket (outputs de infraestrutura)

```bash
# Nome do bucket criado
terraform output bucket_name
# → "myproject-dev-s3pub-8k2m9z"

# ARN para uso em políticas IAM e outros recursos AWS
terraform output bucket_arn
# → "arn:aws:s3:::myproject-dev-s3pub-8k2m9z"

# Endpoint global (path-style)
terraform output bucket_domain_name
# → "myproject-dev-s3pub-8k2m9z.s3.amazonaws.com"

# Endpoint regional (recomendado para CORS e acessos diretos)
terraform output bucket_regional_domain_name
# → "myproject-dev-s3pub-8k2m9z.s3.us-east-1.amazonaws.com"
```

---

## Cenários de Custo

| Cenário | Storage | PUTs/mês | GETs/mês | Egress | Custo mensal |
|---|---|---|---|---|---|
| Dev mínimo | 5 GB | 5K | 50K | 1 GB | **~$0.23** |
| Dev ativo | 10 GB | 10K | 100K | 10 GB | **~$1.22** |
| Staging | 50 GB | 50K | 500K | 50 GB | **~$6.15** |
| Produção leve | 100 GB | 100K | 1M | 100 GB | **~$11.80** |
| Produção com tráfego | 500 GB | 500K | 10M | 500 GB | **~$60.00** |

> O egress é o principal driver de custo em buckets públicos com alto tráfego. Avalie o uso de CloudFront como CDN para reduzir drasticamente esse custo.

---

## Otimização de Custos

```
💡  Use Amazon CloudFront como CDN na frente do S3 público. A transferência de
    dados S3 → CloudFront é gratuita, e o custo de egress do CloudFront é
    $0.0085/GB (primeiros 10 TB) — muito menor que os $0.09/GB diretos do S3.

💡  Habilite S3 Lifecycle Rules para mover objetos antigos para S3 Standard-IA
    ($0.0125/GB/mês) ou S3 Glacier ($0.004/GB/mês) quando não são mais acessados
    frequentemente, reduzindo o custo de armazenamento em até 80%.

💡  Use S3 Intelligent-Tiering para objetos com padrão de acesso imprevisível.
    Ele move automaticamente objetos entre camadas sem custo de recuperação.

💡  Configure S3 Storage Lens ou AWS Cost Explorer para monitorar o volume de
    requisições e identificar picos inesperados de GET que podem inflar o custo.

💡  Evite listagens desnecessárias (LIST = PUT pricing). Prefira guardar metadados
    em DynamoDB ou um banco de dados dedicado em vez de listar o bucket programaticamente.

💡  Prefira endpoints regionais nas aplicações cliente para evitar latência adicional
    e eventual custo de cross-region transfer caso o cliente esteja em outra região.
```

---

> Preços sujeitos a alteração. Consulte sempre a [calculadora oficial da AWS](https://calculator.aws) para estimativas atualizadas antes de decisões orçamentárias.

<p align="center">
  <sub>Gerenciado por Terraform · FinOps S3 Público · Atualizado em Jun/2026</sub>
</p>
