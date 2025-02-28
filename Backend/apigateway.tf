module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 3.0"

  name          = "photo-app-api"
  description   = "API for retrieving image metadata"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["Content-Type", "Authorization"]
  }

  authorizers = {
    cognito = {
      authorizer_type = "JWT"
      identity_source = "$request.header.Authorization"

      issuer = "https://${module.cognito_user_pool.id}.auth.${var.aws_region}.amazoncognito.com"
      audience = [module.cognito_user_pool_client.id]
    }
  }

  integrations = {
    "GET /metadata" = {
      lambda_arn             = module.lambda_function.lambda_function_arn
      payload_format_version = "2.0"
      authorizer_key         = "cognito"
    }
  }
}

#allows API Gateway to invoke our Lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.lambda_function_name
  principal     = "apigateway.amazonaws.com"
}