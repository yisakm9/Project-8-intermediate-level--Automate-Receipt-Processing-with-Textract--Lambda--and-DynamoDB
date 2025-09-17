variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "receipt-processor"
}

variable "environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}