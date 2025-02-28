module "cognito" {
  source  = "terraform-aws-modules/cognito-user-pool/aws"
  version = "~> 3.0"

  name = "photo-app-user-pool"

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  username_attributes = ["email"]
}

module "cognito_user_pool" {
  source  = "terraform-aws-modules/cognito-user-pool/aws"
  version = "~> 3.0"

  name = "photo-app-user-pool"

  username_attributes = ["email"]

  password_policy = {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  auto_verified_attributes = ["email"]
}

module "cognito_user_pool_client" {
  source  = "terraform-aws-modules/cognito-user-pool/aws//modules/user-pool-client"
  version = "~> 3.0"

  user_pool_id = module.cognito_user_pool.id
  name         = "photo-app-client"

  generate_secret              = false
  explicit_auth_flows          = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"
}

module "cognito_user_pool_domain" {
  source  = "terraform-aws-modules/cognito-user-pool/aws//modules/user-pool-domain"
  version = "~> 3.0"

  user_pool_id = module.cognito_user_pool.id
  domain       = "photo-app-auth"
}