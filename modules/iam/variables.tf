variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "receipt_bucket_arn" {
  description = "The ARN of the S3 bucket where receipts are stored."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table for storing receipt data."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the IAM role."
  type        = map(string)
  default     = {}
}