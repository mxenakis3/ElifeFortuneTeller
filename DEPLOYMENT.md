# Fortune Teller - Deployment Guide

Complete guide to deploying the serverless quiz application.

## 🏗️ Architecture

```
User Browser
    ↓
[CloudFront] → [S3] (Static Frontend)
    ↓
[Cognito] (Authentication + JWT)
    ↓
[API Gateway] (REST API + JWT Validation)
    ↓
[Lambda Functions] (Quiz Logic)
    ↓
[DynamoDB] (Quiz Data, Results, Leaderboard)
    ↑
[WebSocket API] → Real-time Updates
```

## 📋 Prerequisites

### 1. AWS Account Setup
- [x] AWS Account ID: `195794488914`
- [x] Region: `us-east-1`
- [x] OIDC Identity Provider for GitHub Actions
- [x] IAM Role: `githubActionsContainerRole`
- [ ] IAM Role updated with serverless permissions

### 2. Tools Required
- Git
- GitHub account with repository access
- AWS CLI (optional, for manual operations)

## 🚀 Deployment Steps

### Step 1: Update IAM Permissions (REQUIRED)

Before any deployment, update your GitHub Actions IAM role:

```bash
# Option A: Via AWS Console
# 1. Go to IAM → Roles → githubActionsContainerRole
# 2. Add permissions → Create inline policy
# 3. Copy contents from infra/global/iam-policy.json
# 4. Name it: ServerlessInfrastructurePolicy

# Option B: Via AWS CLI
aws iam put-role-policy \
  --role-name githubActionsContainerRole \
  --policy-name ServerlessInfrastructurePolicy \
  --policy-document file://infra/global/iam-policy.json
```

**Verify permissions:**
```bash
aws iam get-role-policy \
  --role-name githubActionsContainerRole \
  --policy-name ServerlessInfrastructurePolicy
```

### Step 2: Deploy Terraform Backend (One-Time)

This creates the S3 bucket and DynamoDB table for storing Terraform state.

**Via GitHub Actions (Recommended):**
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select "Terraform Infrastructure" workflow
4. Click "Run workflow" → "Run workflow"
5. Wait ~2 minutes for completion

**Via Local CLI (Alternative):**
```bash
cd infra/global/terraform-state
terraform init
terraform plan
terraform apply
```

**Expected Output:**
```
✅ S3 bucket created: fortune-teller-terraform-state
✅ DynamoDB table created: terraform-state-lock
```

### Step 3: Enable Remote State Backend

After the backend is deployed, enable remote state storage:

1. Edit `infra/envs/dev/main.tf`
2. Uncomment lines 18-24 (the `backend "s3"` block)
3. Commit and push:

```bash
git add infra/envs/dev/main.tf
git commit -m "Enable Terraform remote state backend"
git push origin main
```

### Step 4: Deploy Dev Infrastructure

**Automatic deployment:**
- Push to main branch automatically deploys to dev
- PR to main shows plan without applying

**Manual deployment:**
```bash
cd infra/envs/dev
terraform init
terraform plan
terraform apply
```

### Step 5: Access Your Application

After deployment completes, get the outputs:

```bash
cd infra/envs/dev
terraform output
```

You'll see:
- `api_endpoint` - Use this in your frontend
- `websocket_endpoint` - For real-time features
- `frontend_url` - Your app URL (after frontend is deployed)
- `cognito_user_pool_id` - For authentication
- `cognito_client_id` - For authentication

## 📊 Deployment Status

### Phase 1: Foundation ✅ COMPLETE
- [x] Terraform backend (S3 + DynamoDB)
- [x] Dev environment structure
- [x] IAM policy documentation
- [x] GitHub Actions workflows

### Phase 2: Backend Infrastructure 🚧 IN PROGRESS
- [ ] DynamoDB module (tables for quizzes, results, leaderboard)
- [ ] Cognito module (user authentication)
- [ ] Lambda module (quiz functions)
- [ ] API Gateway module (REST endpoints)
- [ ] WebSocket module (real-time updates)

### Phase 3: Frontend 📅 PLANNED
- [ ] S3/CloudFront module (static hosting)
- [ ] Vanilla JS frontend app
- [ ] Cognito integration
- [ ] API client
- [ ] WebSocket client

### Phase 4: CI/CD Automation 📅 PLANNED
- [ ] Lambda deployment workflow
- [ ] Frontend build and deploy workflow
- [ ] Integration tests

### Phase 5: Production 📅 PLANNED
- [ ] Production environment setup
- [ ] CloudWatch dashboards
- [ ] Alarms and monitoring
- [ ] Cost optimization

## 🔄 Development Workflow

### Making Infrastructure Changes

1. **Create feature branch:**
   ```bash
   git checkout -b feature/add-dynamodb-module
   ```

2. **Make changes:**
   ```bash
   # Edit files in infra/modules/
   # Edit infra/envs/dev/main.tf to use new module
   ```

3. **Create pull request:**
   ```bash
   git add .
   git commit -m "Add DynamoDB module for quiz storage"
   git push origin feature/add-dynamodb-module
   ```

4. **Review Terraform plan:**
   - GitHub Actions comments on PR with plan
   - Review what will be created/modified/destroyed

5. **Merge and deploy:**
   - Merge PR to main
   - GitHub Actions automatically applies to dev

### Deploying to Production

1. **Test thoroughly in dev**
2. **Create production configs** in `infra/envs/prod/`
3. **Run workflow manually:**
   - Actions tab → Terraform Infrastructure → Run workflow
4. **Review prod plan carefully**
5. **Apply manually** (requires additional approval setup)

## 🐛 Troubleshooting

### Issue: "Backend initialization required"
**Cause:** Terraform backend not deployed yet

**Solution:**
```bash
# Run the backend deployment workflow
# OR manually deploy:
cd infra/global/terraform-state
terraform apply
```

### Issue: "Permission denied" errors
**Cause:** IAM role missing permissions

**Solution:**
```bash
# Update IAM policy (see Step 1)
aws iam put-role-policy \
  --role-name githubActionsContainerRole \
  --policy-name ServerlessInfrastructurePolicy \
  --policy-document file://infra/global/iam-policy.json
```

### Issue: "State locked" error
**Cause:** Concurrent Terraform runs or crashed workflow

**Solution:**
```bash
# Wait for other workflows to complete, OR
# Manually unlock (use with caution):
aws dynamodb delete-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"fortune-teller-terraform-state/dev/terraform.tfstate"}}'
```

### Issue: Workflow doesn't trigger
**Cause:** No changes in `infra/` directory

**Solution:** Workflow only triggers on changes to infrastructure files

### Issue: "No such bucket" error
**Cause:** Backend not deployed yet

**Solution:** Deploy backend first (Step 2)

## 📝 Next Steps

1. ✅ **Complete Phase 1** - Foundation setup
2. 🔄 **Update IAM permissions** (Action required)
3. 🔄 **Deploy Terraform backend** (Action required)
4. 📋 **Build DynamoDB module** (Next task)
5. 📋 **Build Cognito module**
6. 📋 **Build Lambda module**
7. 📋 **Build API Gateway module**
8. 📋 **Build WebSocket module**
9. 📋 **Build frontend**
10. 📋 **Deploy to production**

## 📚 Additional Resources

- [Terraform README](infra/README.md) - Infrastructure documentation
- [Workflow README](.github/workflows/README.md) - CI/CD documentation
- [IAM Update Guide](infra/global/UPDATE_IAM_INSTRUCTIONS.md) - Permissions setup
- AWS Console: https://console.aws.amazon.com/
- GitHub Actions: https://github.com/[your-repo]/actions

## 💡 Tips

- Always review Terraform plans before applying
- Test infrastructure changes in dev first
- Keep modules small and focused
- Document all major changes
- Use meaningful commit messages
- Monitor CloudWatch logs for issues
- Check AWS costs regularly

## 🆘 Getting Help

If you encounter issues:
1. Check troubleshooting section above
2. Review GitHub Actions logs
3. Check CloudWatch logs in AWS
4. Review Terraform state: `terraform show`
5. Validate configuration: `terraform validate`

---

**Status:** Phase 1 Complete ✅
**Next:** Update IAM permissions and deploy backend
**Updated:** 2026-01-10
