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
module "iam_roles" {
  source             = "../../modules/iam"
  project_name       = var.project_name
  environment        = var.environment
  receipt_bucket_arn = module.receipt_s3_bucket.receipt_bucket_arn
  dynamodb_table_arn = module.receipt_database.table_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# The original receipt processing function
module "receipt_processor_function" {
  source              = "../../modules/lambda"
  project_name        = var.project_name
  environment         = var.environment
  lambda_iam_role_arn = module.iam_roles.lambda_execution_role_arn # <-- Update reference
  receipt_bucket_id   = module.receipt_s3_bucket.receipt_bucket_id
  dynamodb_table_name = module.receipt_database.table_name
  sender_email        = var.sender_email
  recipient_email     = var.recipient_email
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}



# Add the new SES module
module "ses_identity" {
  source             = "../../modules/ses"
  notification_email = var.sender_email
}

module "presigned_url_function" {
  source              = "../../modules/lambda-presigned-url"
  project_name        = var.project_name
  environment         = var.environment
  lambda_iam_role_arn = module.iam_roles.presigned_url_lambda_role_arn # <-- Reference new role
  upload_bucket_name  = module.receipt_s3_bucket.receipt_bucket_id
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --- ADD THE NEW API GATEWAY MODULE ---
module "api_gateway" {
  source            = "../../modules/apigateway"
  project_name      = var.project_name
  environment       = var.environment
  lambda_invoke_arn = module.presigned_url_function.function_invoke_arn

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}