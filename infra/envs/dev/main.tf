# Main Terraform Configuration for Dev Environment
# This is the entry point for deploying the serverless quiz application

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration - uncomment after running terraform-state setup
  # backend "s3" {
  #   bucket         = "fortune-teller-terraform-state"
  #   key            = "dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Local variables for common resource naming
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# ============================================================================
# MODULES - Will be uncommented as we build them
# ============================================================================

# # DynamoDB Tables Module
# module "dynamodb" {
#   source = "../../modules/dynamodb"
#
#   environment = var.environment
#   name_prefix = local.name_prefix
# }

# # Cognito User Pool Module
# module "cognito" {
#   source = "../../modules/cognito"
#
#   environment = var.environment
#   name_prefix = local.name_prefix
# }

# # Lambda Functions Module
# module "lambda" {
#   source = "../../modules/lambda"
#
#   environment        = var.environment
#   name_prefix        = local.name_prefix
#   dynamodb_tables    = module.dynamodb.table_names
#   user_pool_id       = module.cognito.user_pool_id
# }

# # API Gateway Module
# module "api_gateway" {
#   source = "../../modules/api-gateway"
#
#   environment     = var.environment
#   name_prefix     = local.name_prefix
#   lambda_functions = module.lambda.function_invoke_arns
#   user_pool_arn    = module.cognito.user_pool_arn
# }

# # WebSocket API Module
# module "websocket" {
#   source = "../../modules/websocket-api"
#
#   environment      = var.environment
#   name_prefix      = local.name_prefix
#   lambda_functions = module.lambda.websocket_function_arns
# }

# # S3 + CloudFront Module
# module "frontend" {
#   source = "../../modules/s3-cloudfront"
#
#   environment = var.environment
#   name_prefix = local.name_prefix
# }
