output "receipt_bucket_id" {
  description = "The ID (name) of the S3 bucket for receipt uploads."
  value       = aws_s3_bucket.receipt_bucket.id
}

output "receipt_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.receipt_bucket.arn
}