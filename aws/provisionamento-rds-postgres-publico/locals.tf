locals {
  env_abbrev = {
    development = "dev"
    staging     = "stg"
    production  = "prd"
  }[var.environment]

  # Base de nomenclatura — compartilhada por todos os recursos do módulo
  name_prefix = "${var.project_abbrev}-${local.env_abbrev}-pgpub-${random_string.rds_suffix.result}"

  db_identifier         = local.name_prefix
  db_replica_identifier = "${local.name_prefix}-replica"
}
