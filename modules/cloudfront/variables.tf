variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "s3_bucket_id" {
  description = "The ID (name) of the S3 bucket hosting the frontend assets."
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket (e.g., bucket.s3.us-east-1.amazonaws.com)."
  type        = string
}

variable "api_gateway_id" {
  description = "The ID of the API Gateway for the API origin."
  type        = string
}

variable "aws_region" {
  description = "The AWS region where the API Gateway is deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags for the resources."
  type        = map(string)
  default     = {}
}