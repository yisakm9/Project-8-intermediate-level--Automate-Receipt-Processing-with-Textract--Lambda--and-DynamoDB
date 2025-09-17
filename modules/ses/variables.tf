variable "notification_email" {
  description = "The email address to verify for sending notifications."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}