resource "aws_sns_topic" "s3_alerts" {
  name = "s3-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.s3_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Change this to your email
}

resource "aws_sns_topic" "photo_app_alerts" {
  name = "photo-app-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.photo_app_alerts.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Replace with your email
}