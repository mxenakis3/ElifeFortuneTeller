# GitHub Actions Workflows

This directory contains CI/CD workflows for the Fortune Teller application.

## Workflows

### 1. `ci-cd.yml` - Legacy Application Workflow
- **Purpose**: Original Flask application CI/CD
- **Triggers**: Push/PR to main
- **Jobs**:
  - Build and test Python application
  - Verify AWS OIDC authentication
- **Status**: Keeping for now, will be replaced by serverless workflows

### 2. `terraform-infrastructure.yml` - Infrastructure Deployment ⭐
- **Purpose**: Deploy and manage AWS serverless infrastructure
- **Triggers**:
  - Push to main (auto-deploy dev)
  - PR to main (plan only)
  - Manual dispatch (for prod)

#### Jobs in Terraform Workflow:

**Job 1: `terraform-backend`**
- Deploys S3 bucket and DynamoDB table for Terraform state
- Only runs when `infra/global/terraform-state/` files change
- **First-time setup**: Trigger manually via Actions tab

**Job 2: `terraform-plan-dev`**
- Runs on every PR and push
- Shows what infrastructure changes will be made
- Comments plan on PRs
- Does NOT apply changes

**Job 3: `terraform-apply-dev`**
- Runs only on push to main (after PR merge)
- Applies infrastructure changes to dev environment
- Deploys: DynamoDB, Cognito, Lambda, API Gateway, S3/CloudFront

**Job 4: `terraform-plan-prod`**
- Only runs on manual dispatch
- Plans production infrastructure changes
- Requires manual approval before applying

## Usage

### First-Time Setup

1. **Update IAM Role** (Required before any deployment)
   ```bash
   # Follow instructions in infra/global/UPDATE_IAM_INSTRUCTIONS.md
   aws iam put-role-policy \
     --role-name githubActionsContainerRole \
     --policy-name ServerlessInfrastructurePolicy \
     --policy-document file://infra/global/iam-policy.json
   ```

2. **Deploy Terraform Backend** (One-time)
   - Go to Actions tab on GitHub
   - Select "Terraform Infrastructure" workflow
   - Click "Run workflow" dropdown
   - Click "Run workflow" button
   - This creates the S3 bucket and DynamoDB table for state storage

3. **Enable Remote State** (After backend is deployed)
   - Uncomment the `backend "s3"` block in `infra/envs/dev/main.tf`
   - Commit and push to trigger automatic deployment

### Regular Development Flow

1. **Make Infrastructure Changes**
   - Edit files in `infra/`
   - Create a pull request

2. **Review Plan on PR**
   - GitHub Actions automatically comments with Terraform plan
   - Review what infrastructure will be created/modified/destroyed

3. **Merge to Deploy**
   - Merge PR to main
   - GitHub Actions automatically applies changes to dev environment

4. **Check Deployment**
   - Go to Actions tab
   - View logs of `terraform-apply-dev` job
   - See outputs (API endpoints, CloudFront URL, etc.)

### Deploying to Production

1. **Manual Approval Required**
   - Go to Actions tab
   - Select "Terraform Infrastructure" workflow
   - Click "Run workflow"
   - Select branch: main
   - Click "Run workflow"

2. **Review Production Plan**
   - Wait for `terraform-plan-prod` job to complete
   - Download and review `prod-plan.txt` artifact

3. **Apply Production Changes**
   - Requires additional manual approval step (add later)
   - Currently: Apply manually from local machine

## Workflow Secrets

All authentication uses OIDC, no secrets needed! 🎉

The workflow uses:
- `GITHUB_TOKEN` (automatically provided)
- OIDC role: `arn:aws:iam::195794488914:role/githubActionsContainerRole`

## Workflow Outputs

After successful deployment, the workflow outputs:

**Dev Environment:**
- `api_endpoint` - REST API URL for frontend
- `websocket_endpoint` - WebSocket URL for real-time updates
- `frontend_url` - CloudFront URL to access the app
- `cognito_user_pool_id` - For frontend authentication
- `cognito_client_id` - For frontend authentication

Access outputs via:
```bash
cd infra/envs/dev
terraform output
```

Or view in GitHub Actions logs.

## Troubleshooting

### "Error: Backend initialization required"
**Solution**: The backend hasn't been deployed yet. Run the workflow manually to deploy it first.

### "Error: Permission denied"
**Solution**: Update IAM role with permissions from `infra/global/iam-policy.json`

### "Error: State locked"
**Solution**: Another workflow run is in progress. Wait or manually unlock:
```bash
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"fortune-teller-terraform-state/dev/terraform.tfstate"}}'
```

### "No changes detected"
**Solution**: The infrastructure is already up-to-date. No deployment needed.

### Workflow doesn't trigger
**Solution**: Check that you modified files in `infra/` directory. The workflow only triggers on infrastructure changes.

## Monitoring

View deployment status:
- **GitHub**: Actions tab
- **AWS CloudWatch**: Lambda logs
- **AWS Console**: Check created resources

## Future Workflows (Coming Soon)

- `lambda-deployment.yml` - Deploy Lambda functions separately
- `frontend-deployment.yml` - Build and deploy frontend to S3
- `e2e-tests.yml` - Run integration tests after deployment

## Best Practices

1. ✅ Always create PRs for infrastructure changes
2. ✅ Review Terraform plans before merging
3. ✅ Test in dev before deploying to prod
4. ✅ Keep infrastructure code modular (use modules)
5. ✅ Document all major changes
6. ❌ Never push directly to main
7. ❌ Never manually modify AWS resources managed by Terraform
