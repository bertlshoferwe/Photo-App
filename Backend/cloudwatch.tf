resource "aws_cloudwatch_metric_alarm" "s3_storage_alarm" {
  alarm_name          = "S3-Storage-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BucketSizeBytes"
  namespace          = "AWS/S3"
  period             = 86400  # 1 day
  statistic          = "Average"
  threshold          = 100000000000  # 100 GB
  alarm_description  = "Alarm when S3 bucket exceeds 100GB"
  alarm_actions      = [aws_sns_topic.s3_alerts.arn]

  dimensions = {
    BucketName = "photo-app-bucket"
    StorageType = "StandardStorage"
  }
}

resource "aws_cloudwatch_metric_alarm" "s3_delete_alarm" {
  alarm_name          = "S3-Delete-Operations-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "PutObject"
  namespace          = "AWS/S3"
  period             = 300  # 5 minutes
  statistic          = "Sum"
  threshold          = 50  # More than 50 delete operations in 5 min
  alarm_description  = "Triggers if there are too many delete operations"
  alarm_actions      = [aws_sns_topic.s3_alerts.arn]

  dimensions = {
    BucketName = "photo-app-bucket"
    StorageType = "StandardStorage"
  }
}

# API Gateway 5XX Errors Alarm
resource "aws_cloudwatch_metric_alarm" "api_gateway_errors" {
  alarm_name          = "API-Gateway-5XX-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 10  # Alert if 10+ errors occur in 1 min
  alarm_description   = "Triggers when API Gateway returns 5XX errors"
  alarm_actions       = [aws_sns_topic.photo_app_alerts.arn]
  dimensions = {
    ApiName = "photo-app-api"
  }
}

# S3 Request Failures Alarm
resource "aws_cloudwatch_metric_alarm" "s3_failures" {
  alarm_name          = "S3-Request-Failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "4XXErrors"
  namespace           = "AWS/S3"
  period              = 60
  statistic           = "Sum"
  threshold           = 10  # Alert if 10+ failed requests occur in 1 min
  alarm_description   = "Triggers when S3 has too many failed requests"
  alarm_actions       = [aws_sns_topic.photo_app_alerts.arn]
  dimensions = {
    BucketName = aws_s3_bucket.photo_app_s3.bucket
  }
}

# Lambda Errors Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "Lambda-Function-Errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1  # Alert on any Lambda failure
  alarm_description   = "Triggers when a Lambda function fails"
  alarm_actions       = [aws_sns_topic.photo_app_alerts.arn]
  dimensions = {
    FunctionName = aws_lambda_function.photo_app_lambda.function_name
  }
}