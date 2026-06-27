locals {
  env_abbrev = {
    development = "dev"
    staging     = "stg"
    production  = "prd"
  }[var.environment]

  bucket_name = "${var.project_abbrev}-${local.env_abbrev}-s3pub-${random_string.bucket_suffix.result}"
}
