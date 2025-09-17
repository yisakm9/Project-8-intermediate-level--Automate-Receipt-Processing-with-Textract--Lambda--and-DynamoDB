# data.archive_file "lambda_zip": Packages the Python source code into a .zip file.
# Terraform will automatically create this zip archive during the apply step.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/receipt_processor"
  output_path = "${path.module}/receipt_processor.zip"
}

# resource.aws_lambda_function "receipt_processor": Creates the Lambda function.
resource "aws_lambda_function" "receipt_processor" {
  function_name = "${var.project_name}-processor-${var.environment}"
  role          = var.lambda_iam_role_arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "main.handler"
  runtime = "python3.9"
  timeout = 60 # seconds

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
      SENDER_EMAIL        = var.sender_email
      RECIPIENT_EMAIL     = var.recipient_email
    }
  }

  tags = var.tags
}

# resource.aws_lambda_permission "allow_s3_invoke": Grants the S3 service permission to invoke this Lambda function.
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receipt_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.receipt_bucket_id}"
}

# resource.aws_s3_bucket_notification "bucket_notification": Configures the S3 bucket to trigger the Lambda function.
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.receipt_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.receipt_processor.arn
    events              = ["s3:ObjectCreated:*"] # Trigger on any object creation event
    filter_prefix       = "uploads/" 
    filter_suffix       = ".jpg"            # Optional: only trigger for files in an 'uploads/' folder
  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.receipt_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".png"
  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.receipt_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    filter_suffix       = ".jpeg"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}