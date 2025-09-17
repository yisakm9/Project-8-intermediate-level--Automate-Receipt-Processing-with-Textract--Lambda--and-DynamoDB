#### 📁 `modules/iam/main.tf`


# resource.aws_iam_role "lambda_execution_role": Creates the IAM role that our Lambda function will assume.
# The assume_role_policy allows the Lambda service to use this role.
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# data.aws_iam_policy_document "lambda_policy_document": Constructs the policy in a structured way.
# We are defining the exact permissions our function needs.
data "aws_iam_policy_document" "lambda_policy_document" {
  # Allow creating and writing to CloudWatch Logs for debugging and monitoring.
  statement {
    sid       = "AllowCloudWatchLogging"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # Allow reading objects from the specific S3 receipt bucket.
  statement {
    sid    = "AllowS3ReadAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${var.receipt_bucket_arn}/*" # Note the /* to allow access to objects within the bucket
    ]
  }

  # Allow calling Amazon Textract to analyze documents.
  statement {
    sid    = "AllowTextractAccess"
    effect = "Allow"
    actions = [
      "textract:AnalyzeDocument"
    ]
    resources = ["*"] # Textract actions are not resource-specific
  }

  # Allow writing items to the specific DynamoDB table.
  statement {
    sid    = "AllowDynamoDBWriteAccess"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [var.dynamodb_table_arn]
  }
  
  # Allow sending emails via SES.
  statement {
    sid    = "AllowSESSendEmail"
    effect = "Allow"
    actions = [
      "ses:SendEmail"
    ]
    resources = ["*"] # SES SendEmail requires "*" unless you specify a sending identity ARN
  }
}

# resource.aws_iam_policy "lambda_policy": Creates the IAM policy from the document above.
resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.project_name}-lambda-policy-${var.environment}"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

# resource.aws_iam_role_policy_attachment "attachment": Attaches the policy to the role.
resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_iam_role" "presigned_url_lambda_role" {
  name = "${var.project_name}-presigned-url-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "presigned_url_lambda_policy_document" {
  # Allow creating and writing to CloudWatch Logs
  statement {
    sid       = "AllowCloudWatchLogging"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  # Allow generating a presigned URL to PUT objects into the specific S3 bucket
  statement {
    sid    = "AllowS3PutObject"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.receipt_bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "presigned_url_lambda_policy" {
  name   = "${var.project_name}-presigned-url-policy-${var.environment}"
  policy = data.aws_iam_policy_document.presigned_url_lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "presigned_url_attachment" {
  role       = aws_iam_role.presigned_url_lambda_role.name
  policy_arn = aws_iam_policy.presigned_url_lambda_policy.arn
}