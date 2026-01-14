# ============================================================================
# Required Variables
# ============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# ============================================================================
# User Pool Configuration
# ============================================================================

variable "deletion_protection" {
  description = "Enable deletion protection (ACTIVE or INACTIVE)"
  type        = string
  default     = "INACTIVE"
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "AUDIT"
}

variable "challenge_required_on_new_device" {
  description = "Require challenge on new device"
  type        = bool
  default     = false
}

# ============================================================================
# Token Configuration
# ============================================================================

variable "access_token_validity_hours" {
  description = "Access token validity in hours"
  type        = number
  default     = 1
}

variable "id_token_validity_hours" {
  description = "ID token validity in hours"
  type        = number
  default     = 1
}

variable "refresh_token_validity_days" {
  description = "Refresh token validity in days"
  type        = number
  default     = 30
}

# ============================================================================
# OAuth Configuration
# ============================================================================

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

# ============================================================================
# Domain Configuration
# ============================================================================

variable "create_user_pool_domain" {
  description = "Create Cognito hosted UI domain"
  type        = bool
  default     = true
}

variable "user_pool_domain" {
  description = "Domain prefix for hosted UI (empty for auto-generated)"
  type        = string
  default     = ""
}

# ============================================================================
# Email Configuration
# ============================================================================

variable "email_sending_account" {
  description = "Email sending account (COGNITO_DEFAULT or DEVELOPER)"
  type        = string
  default     = "COGNITO_DEFAULT"
}

# ============================================================================
# Tags
# ============================================================================

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
