resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}
