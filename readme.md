<h1 align="center">🛠 Dev Terraform</h1>
<h3 align="center">Automatizando sua infraestrutura como código</h3>

<p align="center">
  <img alt="Terraform" src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" />
  <img alt="AWS" src="https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white" />
  <img alt="GCP" src="https://img.shields.io/badge/GCP-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" />
  <img alt="Azure" src="https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white" />
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
</p>

---

## 📑 Índice

- [O que é Terraform?](#-o-que-é-terraform)
- [Principais Características](#-principais-características)
- [Como o Terraform funciona?](#-como-o-terraform-funciona)
- [Casos de Uso](#-casos-de-uso)
- [Terraform vs. Outros Softwares](#-terraform-vs-outros-softwares)
- [Provedores Suportados](#-provedores-suportados)
- [Modelos de Computação em Nuvem](#-modelos-de-computação-em-nuvem)
- [Links Úteis](#-links-úteis)

---

## 🔷 O que é Terraform?

**Terraform** é uma ferramenta open source criada pela HashiCorp para construir, alterar e versionar infraestrutura com segurança e eficiência através de código — o conceito de **Infrastructure as Code (IaC)**.

---

## ✅ Principais Características

### 📦 Infraestrutura como Código (IaC)

| Característica | Descrição |
|---|---|
| Open source e declarativo | Define o estado desejado, não os passos para chegar lá |
| Versionamento | Evolução da infraestrutura com histórico e automação |
| Idempotência | Aplicar o mesmo plano múltiplas vezes gera o mesmo resultado |
| Sintaxe high-level (HCL) | Linguagem legível e altamente reutilizável |
| Paridade de ambiente | Ambientes dev, staging e prod com a mesma configuração |

### 📋 Plano de Execução

- **Segurança e previsibilidade** — visualize as mudanças antes de aplicá-las
- **Separação de planejamento e aplicação** — `terraform plan` → `terraform apply`

### 🌐 Suporte Híbrido e Multi-Cloud

- **Agnóstico** — funciona com qualquer provedor de infraestrutura
- Permite provisionar para múltiplos provedores **simultaneamente**

---

## ⚙️ Como o Terraform funciona?

O core do Terraform utiliza duas fontes de entrada:

```
┌─────────────────────────────────────────────────────┐
│                   TERRAFORM CORE                    │
│                                                     │
│  ┌──────────────────┐    ┌──────────────────────┐  │
│  │ Arquivos de      │    │  Estado Atual        │  │
│  │ Configuração     │    │  (terraform.tfstate) │  │
│  │ (estado desejado)│    │                      │  │
│  └────────┬─────────┘    └──────────┬───────────┘  │
│           └──────────┬──────────────┘              │
│                      ▼                              │
│              [ Plano de Execução ]                  │
│                      ▼                              │
│              [ Aplicar Mudanças ]                   │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────┴────────┐
              ▼                 ▼
         Providers           Resources
```

### Providers

Os provedores expõem recursos que possibilitam criar infraestrutura em diferentes plataformas:

| Categoria | Exemplos |
|---|---|
| **IaaS** | AWS, GCP, Azure, OCI, VMware |
| **PaaS** | Kubernetes, Heroku, Digital Ocean |
| **SaaS** | New Relic, Datadog |

---

## 🎯 Casos de Uso

- ✔️ **Criar ou provisionar** nova infraestrutura do zero
- ✔️ **Gerenciar** infraestrutura existente com controle de mudanças
- ✔️ **Replicar** infraestrutura entre ambientes (dev, staging, prod)

---

## ⚖️ Terraform vs. Outros Softwares

Terraform é uma ferramenta de **alto nível de orquestração de infraestrutura**, diferente de:

| Ferramenta | Propósito | Diferença |
|---|---|---|
| Ansible, Puppet, Chef | Gerenciamento de configuração | Terraform não gerencia configuração de SO/app — foca no provisionamento |
| CloudFormation, ARM | IaC de vendor único | Terraform suporta múltiplos provedores simultaneamente |

> 💡 Terraform pode ser combinado com Ansible/Chef para provisionamento + configuração.

---

## ☁️ Provedores Suportados

| Provider | Recursos | Manutenção |
|---|---|---|
| **AWS** | EC2, Lambda, EKS, ECS, VPC, S3, RDS, DynamoDB | HashiCorp AWS Provider |
| **GCP** | Compute Engine, Cloud Storage, Cloud SQL, GKE, BigQuery | Google + HashiCorp |
| **Azure** | Azure Resource Manager (ARM) completo | Microsoft + HashiCorp |
| **Kubernetes** | Deployments, Services, CRDs, Policies, Quotas | HashiCorp |
| **OCI** | Recursos Oracle Cloud Infrastructure via APIs OCI | HashiCorp |

---

## 🏗 Modelos de Computação em Nuvem

```
┌─────────────────────────────────────────────────────────────┐
│                    NÍVEL DE ABSTRAÇÃO                       │
├──────────┬──────────────────────────────────────────────────┤
│  SaaS    │ Aplicação completa (Gmail, Salesforce)           │
├──────────┼──────────────────────────────────────────────────┤
│  FaaS    │ Funções serverless (Lambda, Cloud Functions)     │
├──────────┼──────────────────────────────────────────────────┤
│  PaaS    │ Executáveis e Containers (App Engine, Heroku)    │
├──────────┼──────────────────────────────────────────────────┤
│  CaaS    │ Ferramentas de Gestão (Kubernetes, ECS)          │
├──────────┼──────────────────────────────────────────────────┤
│  IaaS    │ Servidores, Storage, Rede (EC2, GCE, Azure VM)   │
├──────────┼──────────────────────────────────────────────────┤
│  On-prem │ Co-Location / DataCenter próprio                 │
└──────────┴──────────────────────────────────────────────────┘
```

---

## 🔗 Links Úteis

| Recurso | Link |
|---|---|
| 🟠 AWS CLI | [aws.amazon.com/pt/cli](https://aws.amazon.com/pt/cli) |
| 🟣 Terraform Registry | [registry.terraform.io](https://registry.terraform.io/namespaces/hashicorp) |
| 📘 Docs AWS Provider | [registry.terraform.io/providers/hashicorp/aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) |

---

<h4 align="center">
  🚧 Tutorial de instalação — Em construção... 🚀
</h4>

<p align="center">
  <sub>Mantido por <a href="mailto:josenilto@outlook.com">josenilto</a></sub>
</p>
