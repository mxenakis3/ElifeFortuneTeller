# Terraform Backend Infrastructure
# This creates the S3 bucket and DynamoDB table needed to store Terraform state
# This must be deployed FIRST before any other infrastructure

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# S3 Bucket for Terraform State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "global"
    Project     = "fortune-teller"
  }
}

# Enable versioning to keep history of state files
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption for state files
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table for State Locking
# Prevents multiple users from modifying state simultaneously
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"  # On-demand pricing, no capacity planning needed
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"  # String type
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "global"
    Project     = "fortune-teller"
  }
}
