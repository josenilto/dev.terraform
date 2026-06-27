resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}
