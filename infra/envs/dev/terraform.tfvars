# Terraform Variables for Dev Environment

aws_region   = "us-east-1"
environment  = "dev"
project_name = "fortune-teller"

quiz_config = {
  max_questions_per_quiz = 50
  quiz_timeout_minutes   = 30
  enable_leaderboard     = true
}
