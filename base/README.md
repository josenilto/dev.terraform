# Base de Infraestrutura Terraform — AWS & Azure

Estrutura reutilizável para provisionar recursos em **AWS** e **Azure** com suporte a múltiplos ambientes (`dev`, `staging`, `prod`). Use como ponto de partida para qualquer projeto de infraestrutura como código.

---

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Estrutura do Projeto](#2-estrutura-do-projeto)
3. [Pré-requisitos](#3-pré-requisitos)
4. [Configuração de Credenciais](#4-configuração-de-credenciais)
   - [AWS](#aws)
   - [Azure](#azure)
5. [Fluxo de Trabalho](#5-fluxo-de-trabalho)
   - [Inicializar](#inicializar-terraform-init)
   - [Planejar](#planejar-terraform-plan)
   - [Aplicar](#aplicar-terraform-apply)
   - [Destruir](#destruir-terraform-destroy)
6. [Gerenciamento de State](#6-gerenciamento-de-state)
   - [Backend Local](#backend-local-padrão)
   - [Backend Remoto AWS S3](#backend-remoto-aws-s3)
   - [Backend Remoto Azure](#backend-remoto-azure)
7. [Ambientes](#7-ambientes)
8. [Módulos](#8-módulos)
9. [Como Personalizar](#9-como-personalizar)
10. [Erros Comuns](#10-erros-comuns)
11. [Boas Práticas](#11-boas-práticas)

---

## 1. Visão Geral

Este projeto demonstra as seguintes práticas:

| Prática | Como está implementada |
|---|---|
| **Módulos reutilizáveis** | `modules/aws/` e `modules/azure/` — chamados por todos os ambientes |
| **Separação de ambientes** | `environments/dev/`, `staging/`, `prod/` — state independente por ambiente |
| **Variáveis editáveis** | `terraform.tfvars` por ambiente — sem alterar o código dos módulos |
| **Idempotência** | `terraform apply` sempre converge para o estado desejado |
| **Segurança básica** | IMDSv2 obrigatório na EC2, criptografia S3, bloqueio de acesso público |
| **Nomes únicos** | `random_string` evita conflitos em nomes globais (S3, Storage Account) |
| **Tags padronizadas** | `Project`, `Environment`, `ManagedBy` em todos os recursos |

---

## 2. Estrutura do Projeto

```
base/
├── README.md                              ← Este arquivo
│
├── modules/                               ← Módulos reutilizáveis (não editar diretamente)
│   ├── aws/
│   │   ├── rede/                          ← VPC, subnets públicas/privadas, IGW, Security Group
│   │   ├── compute/                       ← Instância EC2 com volume criptografado
│   │   └── storage/                       ← Bucket S3 com versionamento e criptografia
│   └── azure/
│       ├── rede/                          ← VNet, subnets, NSG com regras HTTP/HTTPS/SSH
│       ├── compute/                       ← VM Linux Ubuntu com SSH por chave pública
│       └── storage/                       ← Storage Account com container de blobs
│
└── environments/                          ← Configurações por ambiente (edite aqui)
    ├── dev/
    │   ├── aws/
    │   │   ├── main.tf                    ← Chama os módulos AWS
    │   │   ├── variables.tf               ← Declaração de variáveis
    │   │   ├── outputs.tf                 ← Valores exportados após o apply
    │   │   ├── backend.tf                 ← Configuração de state remoto (comentada)
    │   │   └── terraform.tfvars           ← Valores específicos do ambiente ← EDITE AQUI
    │   └── azure/
    │       └── (mesma estrutura)
    ├── staging/
    │   └── (mesma estrutura, CIDRs 10.1.x.x)
    └── prod/
        └── (mesma estrutura, CIDRs 10.2.x.x)
```

Cada diretório `environments/{env}/{cloud}/` é um **workspace Terraform independente** com seu próprio `terraform.tfstate`. Você roda `terraform init/plan/apply` de dentro de cada diretório.

---

## 3. Pré-requisitos

### Terraform

Versão mínima: **1.5.0**

```bash
# Verificar versão instalada
terraform version

# Instalar via tfenv (recomendado)
brew install tfenv          # macOS
tfenv install 1.9.0
tfenv use 1.9.0

# Windows — baixe o binário em:
# https://developer.hashicorp.com/terraform/install
```

### AWS CLI

```bash
# Instalar
# macOS:   brew install awscli
# Windows: https://aws.amazon.com/pt/cli/

# Verificar
aws --version
```

### Azure CLI

```bash
# Instalar
# macOS:   brew install azure-cli
# Windows: https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli

# Verificar
az --version
```

---

## 4. Configuração de Credenciais

### AWS

Você precisa de credenciais com permissões para criar VPC, EC2, S3 e (opcionalmente) Budgets.

**Opção A — Perfil local (recomendado para desenvolvimento):**

```bash
aws configure
# AWS Access Key ID:     <sua-access-key>
# AWS Secret Access Key: <sua-secret-key>
# Default region name:   us-east-1
# Default output format: json
```

As credenciais ficam em `~/.aws/credentials`. O provider AWS as lê automaticamente.

**Opção B — Variáveis de ambiente (CI/CD):**

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"
```

**Opção C — IAM Role (EC2/ECS/Lambda):**

Nenhuma configuração necessária — o provider usa a role assumida automaticamente.

**Verificar acesso:**

```bash
aws sts get-caller-identity
# Retorna: Account, UserId, Arn — confirma que as credenciais estão funcionando
```

---

### Azure

Você precisa de uma Service Principal com permissão de **Contributor** na subscription.

**Opção A — Login interativo (desenvolvimento):**

```bash
az login
# Abre o navegador para autenticação com sua conta Microsoft

# Verificar subscription ativa
az account show

# Trocar de subscription (se necessário)
az account set --subscription "Nome ou ID da subscription"
```

**Opção B — Service Principal (CI/CD e automação):**

```bash
# 1. Criar Service Principal
az ad sp create-for-rbac \
  --name "terraform-sp" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>

# Saída:
# {
#   "appId":       "...",   → ARM_CLIENT_ID
#   "password":    "...",   → ARM_CLIENT_SECRET
#   "tenant":      "...",   → ARM_TENANT_ID
# }

# 2. Exportar as variáveis de ambiente
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
```

O provider `azurerm` usa essas variáveis automaticamente.

**Verificar acesso:**

```bash
az account list --output table
# Lista subscriptions disponíveis — a ativa tem "IsDefault = true"
```

---

## 5. Fluxo de Trabalho

Navegue até o diretório do ambiente que quer provisionar antes de rodar qualquer comando.

**Exemplo com dev/aws:**

```bash
cd base/environments/dev/aws
```

### Inicializar (`terraform init`)

Baixa os providers e inicializa o backend. **Rode sempre que:**
- Clonar o repositório pela primeira vez
- Adicionar ou alterar providers/módulos
- Mudar a configuração de backend

```bash
terraform init
```

Saída esperada:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
Terraform has been successfully initialized!
```

---

### Planejar (`terraform plan`)

Mostra o que será criado, alterado ou destruído **sem aplicar nada**. Leia com atenção antes de prosseguir.

```bash
terraform plan
```

Para salvar o plano em arquivo (útil em CI/CD):

```bash
terraform plan -out=plano.tfplan
```

Ícones no output:
- `+` — recurso será **criado**
- `~` — recurso será **modificado** (in-place)
- `-/+` — recurso será **destruído e recriado** (cuidado!)
- `-` — recurso será **destruído**

---

### Aplicar (`terraform apply`)

Executa as mudanças planejadas. Por padrão, pede confirmação antes de prosseguir.

```bash
terraform apply
```

Para aplicar sem confirmação (pipelines CI/CD):

```bash
terraform apply -auto-approve
```

Para aplicar um plano salvo:

```bash
terraform apply plano.tfplan
```

Após o apply, os **outputs** são exibidos automaticamente. Para vê-los novamente:

```bash
terraform output
terraform output ec2_public_ip    # saída específica
```

---

### Destruir (`terraform destroy`)

Remove **todos os recursos** gerenciados por este workspace. Use com cautela.

```bash
terraform destroy
```

Para destruir em CI/CD:

```bash
terraform destroy -auto-approve
```

> **Atenção:** em `dev`, `force_destroy = true` no S3 permite destruir o bucket mesmo com objetos. Em `prod`, isso está desabilitado — você precisará esvaziar o bucket manualmente antes.

---

## 6. Gerenciamento de State

O **state** (`terraform.tfstate`) é o arquivo que mapeia os recursos reais para a configuração Terraform. Mantê-lo seguro e acessível é crítico.

### Backend Local (padrão)

Por padrão, o state fica no diretório local em `terraform.tfstate`. **Use somente em dev individual** — nunca commite este arquivo no git.

Adicione ao `.gitignore`:

```gitignore
# Terraform state — nunca commitar
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl   # pode ser commitado se quiser fixar versões de providers
```

---

### Backend Remoto AWS S3

Recomendado para `staging` e obrigatório para `prod`.

**Passo 1 — Criar infraestrutura de state (uma vez por conta AWS):**

```bash
# Bucket S3 para o state (nome globalmente único)
aws s3api create-bucket \
  --bucket meu-projeto-tfstate \
  --region us-east-1

# Habilitar versionamento (permite recuperar state corrompido)
aws s3api put-bucket-versioning \
  --bucket meu-projeto-tfstate \
  --versioning-configuration Status=Enabled

# Habilitar criptografia
aws s3api put-bucket-encryption \
  --bucket meu-projeto-tfstate \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

# Tabela DynamoDB para lock (evita apply simultâneo)
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

**Passo 2 — Configurar o backend:**

No arquivo `backend.tf` do ambiente, descomente e ajuste:

```hcl
terraform {
  backend "s3" {
    bucket         = "meu-projeto-tfstate"
    key            = "dev/aws/terraform.tfstate"   # path único por ambiente
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

**Passo 3 — Re-inicializar para migrar o state:**

```bash
terraform init -reconfigure
# Pergunta: "Do you want to copy existing state?" → yes
```

---

### Backend Remoto Azure

**Passo 1 — Criar infraestrutura de state:**

```bash
# Resource Group para o state
az group create --name tfstate-rg --location eastus

# Storage Account (nome globalmente único, máx 24 chars)
az storage account create \
  --name meuprojetotfstate \
  --resource-group tfstate-rg \
  --location eastus \
  --sku Standard_LRS \
  --min-tls-version TLS1_2

# Container de blobs
az storage container create \
  --name tfstate \
  --account-name meuprojetotfstate
```

**Passo 2 — Configurar o backend:**

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "meuprojetotfstate"
    container_name       = "tfstate"
    key                  = "dev/azure/terraform.tfstate"
  }
}
```

**Passo 3 — Re-inicializar:**

```bash
terraform init -reconfigure
```

---

## 7. Ambientes

Cada ambiente tem **CIDRs de rede exclusivos** para evitar sobreposição (útil se você conectar as VPCs via peering no futuro):

| Ambiente | AWS VPC CIDR | Azure VNet |
|---|---|---|
| `dev` | `10.0.0.0/16` | `10.0.0.0/16` |
| `staging` | `10.1.0.0/16` | `10.1.0.0/16` |
| `prod` | `10.2.0.0/16` | `10.2.0.0/16` |

**Diferenças por ambiente:**

| Configuração | dev | staging | prod |
|---|---|---|---|
| EC2 `instance_type` | `t3.micro` | `t3.small` | `t3.medium` |
| Azure `vm_size` | `Standard_B1s` | `Standard_B2s` | `Standard_D2s_v3` |
| S3 `versioning_enabled` | `false` | `true` | `true` |
| S3 `force_destroy` | `true` | `false` | `false` |
| Azure replicação | `LRS` | `GRS` | `RAGRS` |
| Monitoramento detalhado | desabilitado | desabilitado | habilitado |
| Backend remoto | opcional | recomendado | **obrigatório** |

**Para trabalhar com um ambiente:**

```bash
# AWS dev
cd base/environments/dev/aws
terraform init && terraform plan

# Azure staging
cd base/environments/staging/azure
terraform init && terraform plan
```

Cada ambiente tem seu próprio `terraform.tfstate` — aplicar em `dev` **nunca** afeta `prod`.

---

## 8. Módulos

Os módulos em `modules/` são os blocos de construção. Cada módulo:
- Aceita variáveis como entrada
- Cria recursos de forma independente
- Exporta valores via `outputs.tf`

### AWS `rede`

Cria: VPC + subnets públicas + subnets privadas + Internet Gateway + Route Table + Security Group

```hcl
module "rede" {
  source = "../../../modules/aws/rede"

  project_name         = "meu-projeto"
  environment          = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# Outputs disponíveis:
# module.rede.vpc_id
# module.rede.public_subnet_ids
# module.rede.private_subnet_ids
# module.rede.default_security_group_id
```

### AWS `compute`

Cria: EC2 com volume EBS criptografado (gp3), IMDSv2 obrigatório

```hcl
module "compute" {
  source = "../../../modules/aws/compute"

  project_name       = "meu-projeto"
  environment        = "dev"
  ami_id             = data.aws_ami.amazon_linux_2023.id
  instance_type      = "t3.micro"
  subnet_id          = module.rede.public_subnet_ids[0]
  security_group_ids = [module.rede.default_security_group_id]
}

# Outputs disponíveis:
# module.compute.instance_id
# module.compute.public_ip
# module.compute.private_ip
```

### AWS `storage`

Cria: S3 Bucket com criptografia AES256, bloqueio de acesso público, versionamento configurável

```hcl
module "storage" {
  source = "../../../modules/aws/storage"

  project_name       = "meu-projeto"
  environment        = "dev"
  bucket_suffix      = random_string.bucket_suffix.result
  versioning_enabled = false
  force_destroy      = true
}

# Outputs disponíveis:
# module.storage.bucket_name
# module.storage.bucket_arn
```

### Azure `rede`

Cria: VNet + subnets (via `for_each`) + NSG com regras HTTP/HTTPS/SSH

```hcl
module "rede" {
  source = "../../../modules/azure/rede"

  project_name        = "meu-projeto"
  environment         = "dev"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  subnets = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
  }
}

# Outputs disponíveis:
# module.rede.vnet_id
# module.rede.subnet_ids["public"]
# module.rede.subnet_ids["private"]
```

### Azure `compute`

Cria: Linux VM (Ubuntu 22.04 LTS) com autenticação SSH por chave pública

```hcl
module "compute" {
  source = "../../../modules/azure/compute"

  project_name         = "meu-projeto"
  environment          = "dev"
  location             = "eastus"
  resource_group_name  = azurerm_resource_group.main.name
  vm_size              = "Standard_B1s"
  subnet_id            = module.rede.subnet_ids["public"]
  admin_ssh_public_key = file("~/.ssh/id_rsa.pub")
  enable_public_ip     = true
}
```

### Azure `storage`

Cria: Storage Account + container de blobs, nome com até 24 chars gerado automaticamente

```hcl
module "storage" {
  source = "../../../modules/azure/storage"

  project_name        = "meu-projeto"
  environment         = "dev"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.main.name
  replication_type    = "LRS"
  storage_name_suffix = random_string.storage_suffix.result
}
```

---

## 9. Como Personalizar

### Trocar o nome do projeto

Edite `terraform.tfvars` no ambiente desejado:

```hcl
project_name = "minha-startup"
```

### Adicionar uma nova região

1. Altere `aws_region` (AWS) ou `location` (Azure) no `.tfvars`
2. Ajuste `availability_zones` para as AZs da nova região
3. Rode `terraform plan` para verificar

### Adicionar uma nova subnet ao módulo Azure

No `terraform.tfvars`:

```hcl
subnets = {
  public   = "10.0.1.0/24"
  private  = "10.0.2.0/24"
  database = "10.0.3.0/24"   # nova subnet
}
```

O módulo cria a subnet automaticamente via `for_each`.

### Usar uma AMI específica no AWS

No `terraform.tfvars`:

```hcl
ami_id = "ami-0c02fb55956c7d316"
```

Deixando vazio (`""`), o `main.tf` usa o data source `aws_ami` para buscar a AMI mais recente do Amazon Linux 2023 automaticamente.

### Adicionar scripts de inicialização à EC2

No `terraform.tfvars`:

```hcl
# O user_data pode ser passado como string multiline
```

Ou diretamente no `main.tf` do ambiente:

```hcl
module "compute" {
  ...
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
  EOF
}
```

---

## 10. Erros Comuns

### "Error: No valid credential sources found"

**Causa:** Credenciais AWS não configuradas.

```bash
# Verificar
aws sts get-caller-identity

# Corrigir
aws configure
# ou
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

---

### "AuthorizationFailed" no Azure

**Causa:** A conta/Service Principal não tem permissão na subscription.

```bash
# Verificar subscription ativa
az account show

# Atribuir papel Contributor
az role assignment create \
  --assignee <client-id-ou-email> \
  --role Contributor \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

---

### "Error acquiring the state lock"

**Causa:** Um apply anterior travou sem liberar o lock (processo morto, timeout de rede).

**AWS DynamoDB:**

```bash
# Ver o lock ativo
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"meu-projeto-tfstate/dev/aws/terraform.tfstate"}}'

# Remover o lock (confirme que nenhum apply está rodando)
terraform force-unlock <LOCK_ID>
```

---

### "BucketAlreadyExists" no S3

**Causa:** Nomes de bucket S3 são globalmente únicos. O nome gerado colidiu com outro bucket.

**Solução:** O projeto usa `random_string` para o sufixo do bucket. Se ainda assim colidir (muito raro), rode `terraform apply` novamente — o random é regenerado automaticamente apenas na primeira criação.

---

### "StorageAccountAlreadyTaken" no Azure

**Causa:** O nome da Storage Account é globalmente único. O `storage_name_suffix` colidiu.

**Solução:** Execute `terraform apply` novamente — o `random_string` é regenerado.

---

### "Error: Invalid AMI ID"

**Causa:** O `ami_id` no tfvars está fixo e a AMI foi desabilitada pela Amazon.

**Solução:** Deixe `ami_id = ""` para usar o data source `aws_ami` que busca sempre a versão mais recente do Amazon Linux 2023.

---

### "Changes to outputs are outside the scope of this command"

**Causa:** Você alterou variáveis declaradas em `outputs.tf` de recursos que não existem no state.

**Solução:** Rode `terraform apply` primeiro para criar os recursos, depois `terraform output`.

---

### "terraform init" não encontra os módulos

**Causa:** Você está rodando `terraform init` no diretório errado.

**Solução:** Navegue até o diretório do ambiente específico:

```bash
cd base/environments/dev/aws   # NÃO rode na raiz do projeto
terraform init
```

---

### State local foi deletado acidentalmente

**Causa:** O arquivo `terraform.tfstate` foi removido sem usar backend remoto.

**Consequência:** O Terraform perde o rastreamento dos recursos criados. Ao rodar `terraform plan`, vai querer recriar tudo.

**Como evitar:** Use backend remoto em staging e prod. O S3 com versionamento permite recuperar versões anteriores do state:

```bash
# Listar versões do state no S3
aws s3api list-object-versions \
  --bucket meu-projeto-tfstate \
  --prefix dev/aws/terraform.tfstate
```

---

### Mudança de ambiente destruiu recursos do outro ambiente

**Causa:** Você rodou `terraform apply` no diretório errado.

**Como evitar:** Cada ambiente tem seu próprio diretório e state. Sempre confirme em qual diretório está antes de rodar comandos:

```bash
pwd   # mostra o diretório atual
```

---

## 11. Boas Práticas

### Nunca commite arquivos sensíveis

Adicione ao `.gitignore` na raiz:

```gitignore
# Terraform
**/.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
*.tfvars.local

# Chaves e credenciais
*.pem
*.key
.env
```

---

### Fixe as versões dos providers

O arquivo `.terraform.lock.hcl` (gerado pelo `terraform init`) registra as versões exatas dos providers. Commite-o no repositório para garantir que todos usem a mesma versão:

```bash
git add .terraform.lock.hcl
git commit -m "Fixar versões de providers Terraform"
```

---

### Use `terraform plan -out` antes de apply em staging/prod

```bash
# Salva o plano
terraform plan -out=plano.tfplan

# Revise o plano
terraform show plano.tfplan

# Aplique exatamente o que foi planejado
terraform apply plano.tfplan
```

---

### Valide a formatação e sintaxe antes do commit

```bash
# Formata todos os arquivos .tf
terraform fmt -recursive

# Valida a sintaxe (sem acessar credenciais)
terraform validate
```

---

### Use tags consistentes em todos os recursos

Todos os módulos já herdam as tags via `merge()`:

```hcl
tags = {
  Project     = var.project_name
  Environment = var.environment
  ManagedBy   = "Terraform"
}
```

Adicione tags de negócio no `terraform.tfvars`:

```hcl
tags = {
  Owner      = "josenilto@outlook.com"
  CostCenter = "engenharia"
  Team       = "plataforma"
}
```

---

### Próximos passos para crescer o projeto

1. **Adicionar GCP:** Crie `modules/gcp/rede`, `compute`, `storage` seguindo o mesmo padrão
2. **Pipeline CI/CD:** Configure GitHub Actions ou Azure DevOps para rodar `plan` em PR e `apply` no merge
3. **Módulo de banco de dados:** Adicione `modules/aws/rds` baseado no exemplo existente em `aws/provisionamento-rds-postgres-publico/`
4. **Alertas de custo:** Integre o padrão FinOps já presente nos outros módulos do projeto
5. **Múltiplas regiões:** Duplique os módulos de rede e compute para alta disponibilidade geográfica

---

*Mantido por [josenilto@outlook.com](mailto:josenilto@outlook.com)*
