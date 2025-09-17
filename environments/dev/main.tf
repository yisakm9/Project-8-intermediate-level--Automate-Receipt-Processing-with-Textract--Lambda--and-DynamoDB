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

# Add the new Lambda function module
# Update the Lambda function module call
module "lambda_function" {
  source              = "../../modules/lambda"
  project_name        = var.project_name
  environment         = var.environment
  lambda_iam_role_arn = module.iam_role.lambda_execution_role_arn
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