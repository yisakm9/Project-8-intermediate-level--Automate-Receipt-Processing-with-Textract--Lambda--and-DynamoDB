# Provider and Backend configuration should be in providers.tf and backend.tf respectively.

module "receipt_s3_bucket" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  # We are passing the CloudFront domain name into the S3 module
  allowed_cors_origin = "https://${module.cloudfront.cloudfront_distribution_domain_name}"

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
  source              = "../../modules/apigateway"
  project_name        = var.project_name
  environment         = var.environment
  lambda_invoke_arn   = module.presigned_url_function.function_invoke_arn # Still needed for the integration
  lambda_function_arn = module.presigned_url_function.function_arn      # Pass the standard ARN for permissions

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# --- ADD NEW S3 BUCKET FOR FRONTEND ASSETS ---
module "frontend_s3_bucket" {
  source       = "../../modules/s3"
  # Use a different name to distinguish it from the uploads bucket
  project_name = "${var.project_name}-frontend" 
  environment  = var.environment

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --- ADD THE NEW CLOUDFRONT MODULE ---
module "cloudfront" {
  source                         = "../../modules/cloudfront"
  project_name                   = var.project_name
  environment                    = var.environment
  s3_bucket_id                   = module.frontend_s3_bucket.receipt_bucket_id
  s3_bucket_regional_domain_name = module.frontend_s3_bucket.receipt_bucket_regional_domain_name # We need to add this output to the S3 module
  api_gateway_id                 = module.api_gateway.api_id
  aws_region                     = var.aws_region
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}