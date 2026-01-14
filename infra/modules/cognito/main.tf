# ============================================================================
# AWS Cognito User Pool for Fortune Teller Quiz Application
# ============================================================================

resource "aws_cognito_user_pool" "main" {
  name = "${var.name_prefix}-user-pool"

  # Allow users to sign in with email
  alias_attributes = ["email", "preferred_username"]

  # Users can sign up themselves
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # Standard email attribute
  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 5
      max_length = 254
    }
  }

  # Custom attribute: Quiz count
  schema {
    name                     = "quiz_count"
    attribute_data_type      = "Number"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    number_attribute_constraints {
      min_value = 0
      max_value = 99999
    }
  }

  # Custom attribute: Personality type
  schema {
    name                     = "personality_type"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 50
    }
  }

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # Email verification required
  auto_verified_attributes = ["email"]

  # Email verification message
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your Fortune Teller account"
    email_message        = "Thank you for signing up! Your verification code is {####}."
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  software_token_mfa_configuration {
    enabled = true
  }

  # Account recovery via email
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Advanced security
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Case insensitive email
  username_configuration {
    case_sensitive = false
  }

  # Device tracking
  device_configuration {
    challenge_required_on_new_device      = var.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = true
  }

  # Email configuration
  email_configuration {
    email_sending_account = var.email_sending_account
  }

  # User attribute update settings
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-user-pool"
    }
  )
}

# User Pool Client
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.name_prefix}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # Token validity
  access_token_validity  = var.access_token_validity_hours
  id_token_validity      = var.id_token_validity_hours
  refresh_token_validity = var.refresh_token_validity_days

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  # OAuth flows
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile",
    "aws.cognito.signin.user.admin"
  ]

  # Callback URLs
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Authentication flows
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
  ]

  # Security settings
  generate_secret               = false
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  # Attribute permissions
  read_attributes = [
    "email",
    "email_verified",
    "custom:quiz_count",
    "custom:personality_type",
  ]

  write_attributes = [
    "email",
  ]
}

# User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  count = var.create_user_pool_domain ? 1 : 0

  domain       = var.user_pool_domain != "" ? var.user_pool_domain : "${var.name_prefix}-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}
