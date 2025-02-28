resource "aws_wafv2_web_acl" "photo_app_waf" {
  name        = "photo-app-waf"
  description = "WAF for the Google Photos-like app"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-Managed-SQL-Injection"
    priority = 1
    action {
      block {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLInjectionRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiBlocked"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-Managed-XSS"
    priority = 2
    action {
      block {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCrossSiteScriptingRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSBlocked"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "Rate-Limiting"
    priority = 3
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 2000  # Block IPs exceeding 2000 requests in 5 minutes
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitedBlocked"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "PhotoAppWAF"
    sampled_requests_enabled   = true
  }
}