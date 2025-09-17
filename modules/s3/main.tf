# data.aws_caller_identity "current": Get the current AWS account ID to ensure globally unique bucket names.
data "aws_caller_identity" "current" {}

# resource.aws_s3_bucket "receipt_bucket": Creates the S3 bucket for receipt uploads.
resource "aws_s3_bucket" "receipt_bucket" {
  # Bucket names must be globally unique. We construct a name using project, environment, and account ID.
  bucket = "${var.project_name}-receipts-${var.environment}-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.project_name}-receipts-${var.environment}"
    }
  )
}

# resource.aws_s3_bucket_versioning "versioning": Enables versioning on the S3 bucket.
# This is a critical best practice to protect against accidental overwrites and deletions.
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.receipt_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# resource.aws_s3_bucket_server_side_encryption_configuration "encryption": Enforces server-side encryption.
# All objects uploaded to this bucket will be encrypted by default using AWS-managed keys (SSE-S3).
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.receipt_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# resource.aws_s3_bucket_public_access_block "public_access_block": Blocks all public access.
# This ensures that sensitive receipt data is never accidentally exposed to the internet.
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.receipt_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- ADD THIS NEW RESOURCE ---
# resource.aws_s3_bucket_cors_configuration "cors": Configures CORS for the bucket.
# This is CRITICAL to allow the user's browser (running on the CloudFront domain)
# to make a direct PUT request to this S3 bucket.
resource "aws_s3_bucket_cors_configuration" "cors" {
  count = var.allowed_cors_origin != "" ? 1 : 0
  bucket = aws_s3_bucket.receipt_bucket.id
  
  cors_rule {
    # We need to get the CloudFront domain as an input to this module
    allowed_origins = [var.allowed_cors_origin] 
    allowed_methods = ["PUT", "POST"]
    allowed_headers = ["*"]
  }
}