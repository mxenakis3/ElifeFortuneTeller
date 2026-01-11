# Fortune Teller Infrastructure

Serverless quiz application infrastructure managed with Terraform.

## Architecture Overview

```
User Browser
    ↓
[S3 + CloudFront] (static frontend)
    ↓
[Cognito] (authentication, returns JWT)
    ↓
[API Gateway] (REST API with JWT validation)
    ↓
[Lambda Functions] (quiz logic)
    ↓
[DynamoDB] (data storage)
    ↓
[WebSocket API] (real-time updates)
```

## Directory Structure

```
infra/
├── global/
│   ├── terraform-state/     # S3 + DynamoDB for Terraform state (deploy FIRST)
│   ├── iam-policy.json      # IAM policy for GitHub Actions role
│   └── UPDATE_IAM_INSTRUCTIONS.md
├── modules/
│   ├── dynamodb/            # DynamoDB tables
│   ├── cognito/             # User authentication
│   ├── lambda/              # Lambda functions
│   ├── api-gateway/         # REST API
│   ├── websocket-api/       # WebSocket API
│   ├── s3-cloudfront/       # Frontend hosting
│   └── iam/                 # IAM roles and policies
└── envs/
    ├── dev/                 # Development environment
    └── prod/                # Production environment
```

## Prerequisites

1. **AWS CLI** configured with credentials
2. **Terraform** >= 1.5.0
3. **GitHub Actions OIDC** authentication set up
4. **IAM Role** with serverless permissions (see `global/UPDATE_IAM_INSTRUCTIONS.md`)

## Deployment Steps

### Step 1: Deploy Terraform Backend (One-time setup)

```bash
cd infra/global/terraform-state
terraform init
terraform plan
terraform apply
```

This creates:
- S3 bucket: `fortune-teller-terraform-state`
- DynamoDB table: `terraform-state-lock`

### Step 2: Update IAM Role

Follow instructions in `global/UPDATE_IAM_INSTRUCTIONS.md` to add serverless permissions to your GitHub Actions role.

### Step 3: Initialize Dev Environment

```bash
cd infra/envs/dev
terraform init
```

After the backend is deployed, uncomment the `backend "s3"` block in `main.tf` and run:

```bash
terraform init -migrate-state
```

### Step 4: Deploy Infrastructure

```bash
cd infra/envs/dev
terraform plan
terraform apply
```

## Environment Variables

Terraform outputs will provide:
- `api_endpoint` - REST API URL
- `websocket_endpoint` - WebSocket URL
- `frontend_url` - CloudFront URL
- `cognito_user_pool_id` - For frontend auth
- `cognito_client_id` - For frontend auth

## Modules Status

- [ ] DynamoDB - Not implemented yet
- [ ] Cognito - Not implemented yet
- [ ] Lambda - Not implemented yet
- [ ] API Gateway - Not implemented yet
- [ ] WebSocket API - Not implemented yet
- [ ] S3/CloudFront - Not implemented yet
- [ ] IAM - Not implemented yet

## CI/CD Integration

GitHub Actions workflows will automatically:
1. Run `terraform plan` on PRs
2. Run `terraform apply` on merge to main (dev)
3. Deploy Lambda functions
4. Build and deploy frontend to S3

## Useful Commands

```bash
# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure (careful!)
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Get outputs
terraform output
```

## Troubleshooting

### "Backend initialization required"
Run: `terraform init`

### "Permission denied" errors
Check that your IAM role has the required permissions from `iam-policy.json`

### "State lock" errors
Someone else might be running Terraform. Wait or manually remove the lock:
```bash
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"fortune-teller-terraform-state/dev/terraform.tfstate"}}'
```

## Next Steps

1. Build DynamoDB module for quiz data storage
2. Build Cognito module for user authentication
3. Build Lambda module for quiz logic
4. Build API Gateway module for REST endpoints
5. Build WebSocket module for real-time updates
6. Build S3/CloudFront module for frontend hosting
