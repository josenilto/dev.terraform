locals {
  # ── Padrão de nomenclatura do ACR ────────────────────────────────────────
  #
  #  Formato:  acr{projeto}{ambiente}{sufixo_aleatorio}
  #  Exemplo:  acrfinanceprv8k2m9z
  #
  #  Regras Azure ACR:
  #    - Apenas letras e números (sem hífens ou underscores)
  #    - Entre 5 e 50 caracteres
  #    - Globalmente único
  #
  environment_abbrev = {
    "development" = "dev"
    "staging"     = "stg"
    "production"  = "prd"
  }

  env_short = lookup(local.environment_abbrev, var.environment, var.environment)

  acr_name = "acr${var.project_abbrev}${local.env_short}${random_string.acr_suffix.result}"
}
