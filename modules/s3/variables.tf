variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the S3 bucket."
  type        = map(string)
  default     = {}
}
variable "allowed_cors_origin" {
  description = "The origin domain allowed for CORS requests (e.g., your CloudFront URL)."
  type        = string
  default     = ""
}
variable "block_public_access" {
  description = "Whether to block all public access to the bucket. Should be true for production."
  type        = bool
  default     = true
}