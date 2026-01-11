# Variables for Dev Environment

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "fortune-teller"
}

# Quiz Application Configuration
variable "quiz_config" {
  description = "Configuration for quiz application"
  type = object({
    max_questions_per_quiz = number
    quiz_timeout_minutes   = number
    enable_leaderboard     = bool
  })
  default = {
    max_questions_per_quiz = 50
    quiz_timeout_minutes   = 30
    enable_leaderboard     = true
  }
}
