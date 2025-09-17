data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../src/lambda_presigned_url"
  output_path = "${path.module}/lambda_presigned_url.zip"
}

resource "aws_lambda_function" "presigned_url_generator" {
  function_name = "${var.project_name}-presigned-url-${var.environment}"
  role          = var.lambda_iam_role_arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "main.handler"
  runtime = "python3.9"
  timeout = 10 # seconds

  environment {
    variables = {
      UPLOAD_BUCKET_NAME = var.upload_bucket_name
    }
  }

  tags = var.tags
}