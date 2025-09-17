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

# Add the new DynamoDB module
module "receipt_database" {
  source       = "../../modules/dynamodb"
  project_name = var.project_name
  environment  = var.environment

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Update the IAM module to use the actual DynamoDB ARN
module "iam_role" {
  source             = "../../modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  receipt_bucket_arn = module.receipt_s3_bucket.receipt_bucket_arn
  
  # Replace the placeholder with the real output from our new module
  dynamodb_table_arn = module.receipt_database.table_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}