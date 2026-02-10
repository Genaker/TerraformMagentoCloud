# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability in this project, please report it by:

1. **DO NOT** open a public issue
2. Email the maintainers directly or use GitHub's private vulnerability reporting feature
3. Provide detailed information about the vulnerability, including:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

## Security Best Practices

### Secrets Management

**IMPORTANT:** Never commit sensitive information to version control.

This repository contains Terraform/Terragrunt configurations for AWS infrastructure. Follow these security practices:

1. **Database Passwords**: Use AWS Secrets Manager or SSM Parameter Store instead of hardcoded passwords
2. **AWS Credentials**: Use environment variables, AWS profiles, or IAM roles - never commit credentials
3. **State Files**: Ensure S3 buckets for Terraform state have:
   - Encryption enabled
   - Versioning enabled
   - Restricted access policies
   - MFA delete enabled for production

### Infrastructure Security

1. **Network Security**:
   - Use private subnets for databases and application servers
   - Implement proper security group rules (least privilege)
   - Enable VPC flow logs for monitoring

2. **Database Security**:
   - Enable encryption at rest and in transit
   - Use strong, randomly generated passwords stored in AWS Secrets Manager
   - Enable automated backups with appropriate retention periods
   - Restrict access to specific security groups

3. **Application Security**:
   - Keep AMIs updated with latest security patches
   - Use Systems Manager for patch management
   - Enable CloudWatch logs and alarms

### Security Scanning

We recommend running the following security tools before applying changes:

```bash
# Terraform security scanning with tfsec
docker run --rm -v $(pwd):/src aquasec/tfsec /src

# Terraform security and compliance with Checkov
docker run --rm -v $(pwd):/tf bridgecrew/checkov -d /tf
```

## Supported Versions

This project uses:
- Terraform v1.13.4+
- Terragrunt v0.92.1+
- AWS Provider v6.x

Always use the latest stable versions for security updates.

## Known Security Considerations

1. **Example Configurations**: The configurations in this repository are examples and should be customized for production use
2. **Default Values**: Many default values prioritize cost/simplicity over security for demonstration purposes
3. **LocalStack Testing**: LocalStack testing uses simplified credentials - never use these in production

## Security Checklist for Production Deployment

Before deploying to production, ensure:

- [ ] All secrets are stored in AWS Secrets Manager or SSM Parameter Store
- [ ] Database passwords are rotated regularly
- [ ] S3 backend buckets have encryption and versioning enabled
- [ ] MFA is enabled for AWS accounts with infrastructure access
- [ ] Security groups follow the principle of least privilege
- [ ] All data at rest is encrypted
- [ ] All data in transit uses TLS/SSL
- [ ] CloudWatch alarms are configured for security events
- [ ] AWS CloudTrail is enabled for audit logging
- [ ] Regular security scans are performed
- [ ] Backup and disaster recovery procedures are documented and tested
