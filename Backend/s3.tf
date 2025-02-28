module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "photo-app-storage-${random_id.bucket_id.hex}"
  acl    = "private"

  lifecycle_rule = [
    {
      id      = "move-to-glacier"
      status  = "Enabled"
      filter  = { prefix = "uploads/" }
      
      transitions = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id      = "delete-old-images"
      status  = "Enabled"
      filter  = { prefix = "uploads/" }

      expiration = {
        days = 365  # Delete after 1 year
      }
    }
  ]

 attach_policy = true

  # Enable CloudWatch request metrics
  attach_lifecycle_configuration = true
  attach_monitoring_configuration = true

  notifications = [
    {
      lambda_function_arn = module.lambda_function.lambda_function_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = "uploads/"
    }
  ]

  tags = {
    Name        = "Photo Storage Bucket"
    Environment = "Dev"
  }

}

#Create a S3 bucket for static website
module "s3_static_website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "photo-app-frontend"
  acl    = "public-read"

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

#S3 bucket for cloudtrail logs
module "s3_cloudtrail_logs" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "photo-app-cloudtrail-logs"
  acl    = "private"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [{
    id      = "delete-old-logs"
    status  = "Enabled"
    expiration = {
      days = 365  # Delete logs after 1 year
    }
  }]
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "photo-app-cloudfront-logs"
}

resource "aws_s3_bucket_acl" "cloudfront_logs_acl" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "photo_app_versioning" {
  bucket = aws_s3_bucket.photo_app_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Destination S3 Bucket
resource "aws_s3_bucket" "photo_app_backup_s3" {
  bucket = "photo-app-backup-bucket"
  provider = aws.us-west-2
}

# Enable Replication
resource "aws_s3_bucket_replication_configuration" "photo_app_replication" {
  bucket = aws_s3_bucket.photo_app_s3.id
  role   = aws_iam_role.s3_replication_role.arn

  rule {
    id     = "BackupReplication"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.photo_app_backup_s3.arn
      storage_class = "STANDARD"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "photo_app_lifecycle" {
  bucket = aws_s3_bucket.photo_app_s3.id

  rule {
    id     = "TransitionToGlacier"
    status = "Enabled"

    filter {
      prefix = "photos/"  # Apply to photos directory
    }

    transition {
      days          = 30  # Move to Glacier after 30 days
      storage_class = "GLACIER"
    }

    expiration {
      days = 365  # Expire objects after 365 days
    }
  }
}