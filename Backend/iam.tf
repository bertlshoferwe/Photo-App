resource "aws_iam_role" "photo_app_role" {
  name = "photo-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "photo_app_s3_policy" {
  name        = "photo-app-s3-policy"
  description = "Permissions for accessing S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::photo-app-bucket",
          "arn:aws:s3:::photo-app-bucket/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.photo_app_role.name
  policy_arn = aws_iam_policy.photo_app_s3_policy.arn
}

resource "aws_iam_policy" "jenkins_terraform_policy" {
  name        = "jenkins-terraform-policy"
  description = "Restrict Jenkins to Terraform operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::photo-app-bucket",
          "arn:aws:s3:::photo-app-bucket/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole",
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction",
          "cloudwatch:PutMetricAlarm"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "jenkins_policy_attach" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = aws_iam_policy.jenkins_terraform_policy.arn
}

# IAM Role for Replication
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Replication
resource "aws_iam_policy" "s3_replication_policy" {
  name        = "s3-replication-policy"
  description = "Policy for S3 replication"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:ReplicateObject", "s3:ReplicateDelete"]
      Resource = [
        aws_s3_bucket.photo_app_s3.arn,
        aws_s3_bucket.photo_app_backup_s3.arn
      ]
    }]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "replication_attachment" {
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}