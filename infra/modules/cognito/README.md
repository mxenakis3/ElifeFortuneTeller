# Cognito User Pool Module

AWS Cognito authentication module for the Fortune Teller personality quiz application.

## Features

- Email-based authentication
- Email verification required
- Optional MFA (TOTP)
- Custom attributes: `quiz_count`, `personality_type`
- Hosted UI with OAuth support
- Advanced security (compromised credentials check)
- JWT token generation for API authentication

## Usage

```hcl
module "cognito" {
  source = "../../modules/cognito"

  name_prefix = "fortune-teller-dev"
  environment = "dev"
  aws_region  = "us-east-1"

  callback_urls = ["http://localhost:3000/callback"]
  logout_urls   = ["http://localhost:3000"]
}
```

## Outputs

- `user_pool_id` - For frontend configuration
- `user_pool_client_id` - For frontend configuration
- `hosted_ui_url` - URL to test authentication
- `user_pool_arn` - For API Gateway JWT validation
- `frontend_config` - Complete frontend configuration object

## Integration

### Frontend (JavaScript)
```javascript
const config = {
  region: outputs.frontend_config.region,
  userPoolId: outputs.frontend_config.userPoolId,
  userPoolWebClientId: outputs.frontend_config.userPoolWebClientId
};
```

### API Gateway
Uses `user_pool_arn` for JWT validation

### Lambda
Access user info from JWT claims in event context

## Cost

Free tier: Up to 50,000 monthly active users
