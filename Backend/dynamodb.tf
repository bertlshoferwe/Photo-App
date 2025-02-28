module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 2.0"

  name         = "photo-app-metadata"
  hash_key     = "image_id"
  billing_mode = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "image_id"
      type = "S"
    },
    {
      name = "upload_time"
      type = "N"
    }
  ]

  global_secondary_indexes = [
    {
      name               = "upload_time-index"
      hash_key           = "upload_time"
      projection_type    = "ALL"
    }
  ]

  tags = {
    Name        = "Photo Metadata Table"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "photo_app_dynamodb" {
  name           = "photo-app-dynamodb"
  hash_key       = "user_id"
  range_key      = "photo_id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  # Enable Auto Scaling for Read and Write capacity
  global_secondary_index {
    name               = "PhotoIndex"
    hash_key           = "photo_id"
    range_key          = "user_id"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }

  auto_scaling {
    read {
      min_capacity = 5
      max_capacity = 20
      target_value = 70
    }
    write {
      min_capacity = 5
      max_capacity = 20
      target_value = 70
    }
  }
}