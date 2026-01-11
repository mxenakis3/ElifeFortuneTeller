# Outputs for Dev Environment
# These will be populated as we add modules

# output "api_endpoint" {
#   description = "API Gateway endpoint URL"
#   value       = module.api_gateway.api_endpoint
# }

# output "websocket_endpoint" {
#   description = "WebSocket API endpoint URL"
#   value       = module.websocket.websocket_endpoint
# }

# output "frontend_url" {
#   description = "CloudFront distribution URL for frontend"
#   value       = module.frontend.cloudfront_url
# }

# output "cognito_user_pool_id" {
#   description = "Cognito User Pool ID"
#   value       = module.cognito.user_pool_id
# }

# output "cognito_client_id" {
#   description = "Cognito User Pool Client ID"
#   value       = module.cognito.user_pool_client_id
# }

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}
