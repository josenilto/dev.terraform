resource "random_string" "rds_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}
