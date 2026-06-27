# 💰 FinOps — Azure Container Registry Público

> Documentação de custos, padrão de nomenclatura e controle orçamentário do recurso ACR provisionado via Terraform.

---

## 📑 Índice

- [Padrão Único de Nome — acr\_name](#-padrão-único-de-nome--acr_name)
- [Estimativa de Custo Mensal por SKU](#-estimativa-de-custo-mensal-por-sku)
- [Controle de Orçamento — Budget Alerts](#-controle-de-orçamento--budget-alerts)
- [Outputs FinOps](#-outputs-finops)
- [Como ajustar o orçamento](#-como-ajustar-o-orçamento)

---

## 🏷 Padrão Único de Nome — `acr_name`

O nome do ACR é **gerado automaticamente** pelo provider `hashicorp/random` para garantir unicidade global no Azure, sem intervenção manual.

### Composição do nome

```
acr  +  {project_prefix}  +  {6 chars aleatórios}
 ↓            ↓                      ↓
"acr"      "devops"             "ab3f2c"

 resultado → acrdevopsab3f2c
```

### Regras de formação

| Segmento | Origem | Restrição |
|---|---|---|
| `acr` | Prefixo fixo | Identifica o tipo de recurso |
| `{project_prefix}` | Variável `project_prefix` | Letras minúsculas e números, 3–20 chars |
| `{6 chars aleatórios}` | `random_string` | Letras minúsculas + números, sem especiais |

### Implementação em `acr.tf`

```hcl
resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

locals {
  acr_name = "acr${var.project_prefix}${random_string.acr_suffix.result}"
}
```

### Exemplos de nomes gerados

| `project_prefix` | Sufixo gerado | Nome final |
|---|---|---|
| `devops` | `ab3f2c` | `acrdevopsab3f2c` |
| `producao` | `7x9k1m` | `acrproducao7x9k1m` |
| `staging` | `e4r2t1` | `acrstaging e4r2t1` |

> **Importante:** o sufixo é gravado no `terraform.tfstate` após o primeiro `apply` e **não muda** em execuções subsequentes. Para gerar um novo nome, use `terraform taint random_string.acr_suffix`.

### Validação do prefixo

```hcl
variable "project_prefix" {
  validation {
    condition     = can(regex("^[a-z0-9]{3,20}$", var.project_prefix))
    error_message = "O prefixo deve conter apenas letras minúsculas e números, entre 3 e 20 caracteres."
  }
}
```

---

## 💵 Estimativa de Custo Mensal por SKU

Os valores abaixo são referência da tabela de preços Azure (região East US) e estão mapeados no `finops.tf`.

### Custo fixo do registry (USD/mês)

| SKU | Fee Mensal | Indicado para |
|---|---|---|
| **Basic** | $5,00 | Desenvolvimento e testes |
| **Standard** | $20,00 | Produção com uso moderado |
| **Premium** | $50,00 | Produção com geo-replicação e alta disponibilidade |

### Custo variável (acumulado ao fee mensal)

| Componente | Custo |
|---|---|
| Storage | $0,10 / GB / mês |
| Operações (push/pull) | $0,01 / 10.000 operações |

### Exemplo de custo real — SKU Basic

```
Registry fee          →  $5,00/mês
Storage (10 GB)       →  $1,00/mês   (10 GB × $0,10)
Operações (500K ops)  →  $0,50/mês   (50 × $0,01)
                         ─────────
Total estimado        →  $6,50/mês
```

> O budget configurado atualmente é de **$30,00/mês**, com margem para crescimento de uso e picos pontuais.

---

## 🔔 Controle de Orçamento — Budget Alerts

O recurso `azurerm_consumption_budget_resource_group` monitora o custo mensal do Resource Group e dispara alertas por e-mail em três níveis progressivos.

### Fluxo de alertas

```
Custo mensal acumulado
        │
        ├── > 80% do budget ($24,00)  →  ⚠️  Alerta preventivo     → e-mail
        │
        ├── > 100% do budget ($30,00) →  🚨  Limite atingido        → e-mail
        │
        └── > 110% projetado ($33,00) →  📊  Forecast acima do limit → e-mail
```

### Configuração atual (`terraform.tfvars`)

```hcl
budget_amount_monthly = 30
budget_start_date     = "2026-06-01T00:00:00Z"
budget_contact_emails = ["josenilto@outlook.com"]
```

### Detalhamento dos alertas

| # | Threshold | Tipo | Trigger | Valor de referência |
|---|---|---|---|---|
| 1 | 80% | `Actual` | Custo real acumulado | $24,00 |
| 2 | 100% | `Actual` | Custo real acumulado | $30,00 |
| 3 | 110% | `Forecasted` | Projeção até fim do mês | $33,00 |

> O alerta `Forecasted` é disparado quando o Azure projeta que o custo final do mês ultrapassará 110% do budget, mesmo que o custo atual ainda esteja abaixo do limite.

---

## 📤 Outputs FinOps

Após `terraform apply`, os seguintes outputs estão disponíveis:

```bash
terraform output finops_budget_name
# → "budget-acrdevopsab3f2c-mensal"

terraform output finops_budget_amount_usd
# → 30

terraform output finops_estimated_monthly_cost_usd
# → 5   (fee base do SKU Basic)
```

| Output | Descrição |
|---|---|
| `finops_budget_name` | Nome do budget criado no Azure Cost Management |
| `finops_budget_amount_usd` | Limite mensal configurado em USD |
| `finops_estimated_monthly_cost_usd` | Fee base do SKU (sem storage e operações) |

---

## 🔧 Como ajustar o orçamento

### Alterar o limite mensal

Edite `terraform.tfvars` e aplique:

```hcl
budget_amount_monthly = 50   # novo limite em USD
```

```bash
terraform plan
terraform apply
```

### Adicionar destinatários de alerta

```hcl
budget_contact_emails = [
  "josenilto@outlook.com",
  "time-infra@empresa.com"
]
```

### Trocar o SKU e rever o budget

| Mudança | Budget recomendado |
|---|---|
| Basic → Standard | Aumentar para $50/mês |
| Basic → Premium | Aumentar para $100/mês |

### Verificar custos no Azure Portal

```
Portal Azure → Cost Management + Billing
  → Budgets → budget-acr{nome}-mensal
  → Cost Analysis → Resource Group: rg-acr-publico
```

---

<p align="center">
  <sub>Gerenciado por Terraform · FinOps ACR Público · Atualizado em Jun/2026</sub>
</p>
