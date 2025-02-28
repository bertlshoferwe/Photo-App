resource "aws_cloudtrail" "s3_trail" {
  name           = "photo-app-trail"
  s3_bucket_name = module.s3_cloudtrail_logs.s3_bucket_id
  is_multi_region_trail = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::photo-app-bucket/"]
    }
  }
}
