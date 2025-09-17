# Provider and Backend configuration should be in providers.tf and backend.tf respectively.

module "receipt_s3_bucket" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}