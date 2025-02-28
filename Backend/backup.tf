resource "aws_backup_vault" "photo_app_backup_vault" {
  name = "photo-app-backup-vault"
}

# Backup Plan
resource "aws_backup_plan" "photo_app_backup_plan" {
  name = "photo-app-backup-plan"

  rule {
    rule_name         = "DailyBackups"
    target_vault_name = aws_backup_vault.photo_app_backup_vault.name
    schedule         = "cron(0 12 * * ? *)"  # Every day at 12 PM UTC

    lifecycle {
      delete_after = 30  # Keep backups for 30 days
    }
  }
}

# Backup DynamoDB
resource "aws_backup_selection" "backup_dynamodb" {
  name         = "backup-dynamodb"
  iam_role_arn = aws_iam_role.s3_replication_role.arn
  plan_id      = aws_backup_plan.photo_app_backup_plan.id

  resources = [
    aws_dynamodb_table.photo_app_dynamodb.arn
  ]
}

# Backup Lambda
resource "aws_backup_selection" "backup_lambda" {
  name         = "backup-lambda"
  iam_role_arn = aws_iam_role.s3_replication_role.arn
  plan_id      = aws_backup_plan.photo_app_backup_plan.id

  resources = [
    aws_lambda_function.photo_app_lambda.arn
  ]
}