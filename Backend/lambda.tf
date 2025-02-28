module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.0"

  function_name = "photo-app-processor"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  memory_size = 128
  timeout     = 10

  source_path = "lambda_function.zip"
  role        = module.lambda_role.iam_role_arn
}

#ensures that the S3 bucket is allowed to trigger the Lambda function
resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3_bucket.this_bucket_arn
}

#Allows the lambda function to analyze images and allows to write metadata to the database
module "lambda_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 5.0"

  role_name         = "photo-app-lambda-role"
  create_role       = true
  trusted_role_services = ["lambda.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]
}

resource "aws_lambda_function" "photo_app_lambda" {
  function_name    = "photo-app-lambda"
  runtime         = "python3.8"
  role            = aws_iam_role.photo_app_role.arn
  handler         = "lambda_function.lambda_handler"
  filename        = "lambda_function.zip"
}

resource "aws_application_auto_scaling_target" "photo_app_lambda_scaling" {
  max_capacity       = 100
  min_capacity       = 1
  resource_id        = "function:${aws_lambda_function.photo_app_lambda.function_name}"
  scalable_dimension = "lambda:function:ProvisionedConcurrency"
  service_namespace  = "aws.lambda"
}

resource "aws_application_auto_scaling_policy" "photo_app_lambda_scaling_policy" {
  name                   = "photo-app-lambda-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = "function:${aws_lambda_function.photo_app_lambda.function_name}"
  scalable_dimension     = "lambda:function:ProvisionedConcurrency"
  service_namespace      = "aws.lambda"
  target_tracking_scaling_policy_configuration {
    target_value               = 50.0  # Target to maintain 50% utilization
    predefined_metric_specification {
      predefined_metric_type = "LambdaProvisionedConcurrencyUtilization"
    }
    estimated_instance_warmup  = 60
    scale_in_cooldown         = 60
    scale_out_cooldown        = 60
  }
}