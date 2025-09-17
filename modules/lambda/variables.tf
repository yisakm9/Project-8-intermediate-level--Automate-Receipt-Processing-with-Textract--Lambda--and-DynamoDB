variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "lambda_iam_role_arn" {
  description = "The ARN of the IAM role for the Lambda function."
  type        = string
}

variable "receipt_bucket_id" {
  description = "The ID of the S3 bucket for receipts."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}