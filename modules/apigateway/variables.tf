variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "The invoke ARN of the Lambda function to integrate with."
  type        = string
}

variable "tags" {
  description = "A map of tags for the resources."
  type        = map(string)
  default     = {}
}

variable "lambda_function_arn" {
  description = "The standard ARN of the Lambda function for setting permissions."
  type        = string
}