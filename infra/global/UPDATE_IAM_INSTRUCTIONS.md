# IAM Role Update Instructions

Your existing GitHub Actions OIDC role needs additional permissions for the serverless infrastructure.

**Existing Role ARN:** `arn:aws:iam::195794488914:role/githubActionsContainerRole`

## Option 1: Update via AWS Console (Easiest)

1. Go to AWS Console → IAM → Roles
2. Search for `githubActionsContainerRole`
3. Click on the role
4. Click "Add permissions" → "Create inline policy"
5. Click "JSON" tab
6. Copy the contents of `iam-policy.json` and paste it
7. Click "Review policy"
8. Name it: `ServerlessInfrastructurePolicy`
9. Click "Create policy"

## Option 2: Update via AWS CLI

```bash
# First, validate the policy JSON
aws iam validate-policy --policy-document file://infra/global/iam-policy.json

# Create and attach the inline policy
aws iam put-role-policy \
  --role-name githubActionsContainerRole \
  --policy-name ServerlessInfrastructurePolicy \
  --policy-document file://infra/global/iam-policy.json
```

## Option 3: Update via Terraform (Recommended for IaC)

If you want to manage this with Terraform, you can run:

```bash
cd infra/global/terraform-state
terraform init
terraform apply
```

This will create the S3 backend and can optionally update the IAM role.

## Verify Permissions

After updating, you can test the permissions in your GitHub Actions workflow:

```yaml
- name: Test AWS Permissions
  run: |
    echo "Testing S3 access..."
    aws s3 ls s3://fortune-teller-terraform-state || echo "S3 access not working yet"

    echo "Testing DynamoDB access..."
    aws dynamodb describe-table --table-name terraform-state-lock || echo "DynamoDB access not working yet"

    echo "Testing Lambda permissions..."
    aws lambda list-functions --max-items 1 || echo "Lambda access not working yet"
```

## Required Services

The updated policy grants permissions for:
- ✅ S3 (Terraform state + frontend hosting)
- ✅ DynamoDB (Terraform state locking + quiz data)
- ✅ Lambda (serverless compute)
- ✅ API Gateway (REST API + WebSocket)
- ✅ Cognito (user authentication)
- ✅ CloudFront (CDN)
- ✅ IAM (role management)
- ✅ CloudWatch Logs (monitoring)
- ✅ EventBridge (event routing)

## Security Notes

- This policy uses `"Resource": "*"` for simplicity during development
- For production, consider restricting resources to specific ARNs
- The policy follows least-privilege principles for each service
- OIDC authentication means no long-lived credentials are stored
