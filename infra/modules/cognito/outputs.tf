# ============================================================================
# User Pool Outputs
# ============================================================================

output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

# ============================================================================
# User Pool Client Outputs
# ============================================================================

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.web_client.id
}

# ============================================================================
# Domain Outputs
# ============================================================================

output "user_pool_domain" {
  description = "Domain of the Cognito User Pool"
  value       = var.create_user_pool_domain ? aws_cognito_user_pool_domain.main[0].domain : ""
}

output "hosted_ui_url" {
  description = "URL of the Cognito hosted UI"
  value = var.create_user_pool_domain ? (
    "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${var.aws_region}.amazoncognito.com"
  ) : ""
}

# ============================================================================
# Frontend Configuration Output
# ============================================================================

output "frontend_config" {
  description = "Configuration object for frontend"
  value = {
    region              = var.aws_region
    userPoolId          = aws_cognito_user_pool.main.id
    userPoolWebClientId = aws_cognito_user_pool_client.web_client.id

    oauth = {
      domain          = var.create_user_pool_domain ? aws_cognito_user_pool_domain.main[0].domain : ""
      scope           = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
      redirectSignIn  = length(var.callback_urls) > 0 ? var.callback_urls[0] : ""
      redirectSignOut = length(var.logout_urls) > 0 ? var.logout_urls[0] : ""
      responseType    = "code"
    }

    hostedUI = var.create_user_pool_domain ? (
      "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${var.aws_region}.amazoncognito.com"
    ) : ""
  }
}

# ============================================================================
# API Gateway Integration Outputs
# ============================================================================

output "user_pool_arn_for_api_gateway" {
  description = "User Pool ARN for API Gateway authorizer"
  value       = aws_cognito_user_pool.main.arn
}

output "jwt_issuer" {
  description = "JWT issuer URL for API Gateway"
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
}
