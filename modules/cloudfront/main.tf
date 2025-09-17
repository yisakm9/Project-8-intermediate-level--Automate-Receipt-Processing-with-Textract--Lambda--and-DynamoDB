# resource.aws_cloudfront_origin_access_control "oac": Creates an OAC, the modern way to grant CloudFront secure access to a private S3 bucket.
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac-${var.environment}"
  description                       = "Origin Access Control for the frontend S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# resource.aws_cloudfront_distribution "cdn": The main CDN distribution.
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html" # Serve index.html for root requests

  origin {
    domain_name = var.s3_bucket_regional_domain_name
    origin_id   = "s3-${var.s3_bucket_id}" # A local identifier for this origin
    
    # Attach the OAC to this S3 origin
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    # The domain for the API Gateway origin is constructed from its ID and region.
    domain_name = "${var.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com"
    origin_id   = "apigw-${var.api_gateway_id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default behavior for traffic that doesn't match other rules (serves the UI)
  default_cache_behavior {
    target_origin_id       = "s3-${var.s3_bucket_id}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" 
  }

  # Ordered behavior for API traffic
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "apigw-${var.api_gateway_id}"
    
    # For APIs, we forward all headers and cookies and disable caching.
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # Use a managed policy for caching and forwarding that's ideal for APIs
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # Managed-CachingDisabled
    origin_request_policy_id = "b689b0a8-53d0-40ab-baf2-68738e2966ac" # Managed-AllViewer
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.tags
}

# data.aws_iam_policy_document "s3_policy_document": Defines the policy that allows CloudFront to read from our private S3 bucket.
data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  }
}

# resource.aws_s3_bucket_policy "policy": Attaches the above policy to the frontend S3 bucket.
resource "aws_s3_bucket_policy" "policy" {
  bucket = var.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy_document.json
}