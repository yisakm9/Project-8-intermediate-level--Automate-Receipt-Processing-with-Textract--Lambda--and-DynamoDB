output "frontend_s3_bucket_name" {
  description = "The name of the S3 bucket for the frontend assets."
  value       = module.frontend_s3_bucket.receipt_bucket_id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = module.cloudfront.cloudfront_distribution_domain_name
}