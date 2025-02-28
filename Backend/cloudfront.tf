resource "aws_cloudfront_distribution" "photo_app_cdn" {
  origin {
    domain_name = aws_s3_bucket.photo_app_s3.bucket_regional_domain_name
    origin_id   = "S3-photo-app-origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id = "S3-photo-app-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

        min_ttl     = 60
    default_ttl = 86400
    max_ttl     = 31536000

  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  web_acl_id = aws_wafv2_web_acl.photo_app_waf.arn  # Attach WAF to CloudFront

  viewer_certificate {
    cloudfront_default_certificate = true
  }

   logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
    prefix          = "logs/"
  }
}