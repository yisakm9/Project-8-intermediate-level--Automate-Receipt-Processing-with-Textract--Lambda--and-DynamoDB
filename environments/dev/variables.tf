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
variable "sender_email" {
  description = "The email address notifications will be sent from. Must be verified in SES."
  type        = string
}

variable "recipient_email" {
  description = "The email address that will receive the notification emails."
  type        = string
}