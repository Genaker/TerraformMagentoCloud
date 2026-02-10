# Secrets Management Guide

## Overview

This guide explains how to properly manage secrets for your Magento Cloud infrastructure on AWS.

## ⚠️ Important Security Note

**NEVER commit passwords, API keys, or other sensitive data to version control!**

The example configurations in this repository contain placeholder passwords for demonstration purposes only. These **MUST** be replaced before deploying to production.

## Recommended Approach: AWS Secrets Manager

### 1. Store Database Password in AWS Secrets Manager

```bash
# Create a secret for the database password
aws secretsmanager create-secret \
  --name magento/db/master-password \
  --description "Magento RDS master password" \
  --secret-string '{"password":"YOUR_STRONG_RANDOM_PASSWORD_HERE"}' \
  --region ap-southeast-1
```

### 2. Update RDS Module to Use Secrets Manager

Modify `magento-cloud-minimal/production/mysql/terragrunt.hcl`:

```hcl
# Add data source to fetch secret
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "magento/db/master-password"
}

inputs = {
  # ... other inputs ...
  
  # Use password from Secrets Manager
  password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
  
  # ... other inputs ...
}
```

### 3. Grant IAM Permissions

Ensure your EC2 instances have permissions to read the secret:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "arn:aws:secretsmanager:ap-southeast-1:*:secret:magento/db/*"
    }
  ]
}
```

## Alternative: AWS Systems Manager Parameter Store

### 1. Store Password in Parameter Store

```bash
# Create a secure string parameter
aws ssm put-parameter \
  --name /magento/db/master-password \
  --value "YOUR_STRONG_RANDOM_PASSWORD_HERE" \
  --type SecureString \
  --region ap-southeast-1
```

### 2. Update Terragrunt Configuration

```hcl
# Add data source
data "aws_ssm_parameter" "db_password" {
  name            = "/magento/db/master-password"
  with_decryption = true
}

inputs = {
  # ... other inputs ...
  
  password = data.aws_ssm_parameter.db_password.value
  
  # ... other inputs ...
}
```

## Using Terraform Variables (For Non-Production)

For development/testing environments, you can use Terraform variables:

### 1. Create `terraform.tfvars` (NEVER COMMIT THIS FILE!)

```hcl
db_password = "your_test_password_here"
```

### 2. Update Configuration to Accept Variable

```hcl
# In variables.tf or inline
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

inputs = {
  password = var.db_password
}
```

### 3. Ensure .gitignore Excludes tfvars Files

The repository already includes `*.tfvars` in `.gitignore` to prevent accidental commits.

## Environment Variables

For CI/CD pipelines, use environment variables:

```bash
export TF_VAR_db_password="your_password_here"
```

Terragrunt will automatically use environment variables prefixed with `TF_VAR_`.

## Password Requirements

For production databases, use passwords that meet these criteria:

- At least 16 characters long
- Include uppercase and lowercase letters
- Include numbers
- Include special characters
- Randomly generated (use a password manager or generator)
- Unique (not reused from other systems)

### Generate Strong Passwords

```bash
# Using OpenSSL
openssl rand -base64 32

# Using pwgen (if installed)
pwgen -s 32 1

# Using Python
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

## Secrets Rotation

Implement regular password rotation for production systems:

1. **AWS Secrets Manager** provides automatic rotation
2. Configure rotation schedule (e.g., every 90 days)
3. Use AWS Lambda for custom rotation logic

Example rotation configuration:

```bash
aws secretsmanager rotate-secret \
  --secret-id magento/db/master-password \
  --rotation-lambda-arn arn:aws:lambda:ap-southeast-1:123456789012:function:SecretsManagerRotation \
  --rotation-rules AutomaticallyAfterDays=90
```

## Quick Fix for Current Repository

To secure the current repository, replace the hardcoded password:

1. **Before deploying to production**, update `magento-cloud-minimal/production/mysql/terragrunt.hcl`:

   ```hcl
   # REMOVE THIS:
   password = "CPqBueCwW6n7"
   
   # REPLACE WITH ONE OF:
   # Option 1: Reference to Secrets Manager
   password = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["password"]
   
   # Option 2: Reference to Parameter Store
   password = data.aws_ssm_parameter.db_password.value
   
   # Option 3: Variable for non-production
   password = var.db_password
   ```

2. Store the actual password securely using one of the methods above

3. Never use the example password `CPqBueCwW6n7` in any real deployment

## Additional Resources

- [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)
- [AWS Systems Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
- [Terraform Sensitive Data](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables)
- [AWS RDS Security Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_BestPractices.Security.html)
