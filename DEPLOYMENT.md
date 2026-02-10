# Deployment Guide

This guide provides step-by-step instructions for deploying the Magento Cloud infrastructure on AWS.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Pre-Deployment Checklist](#pre-deployment-checklist)
- [Deployment Steps](#deployment-steps)
- [Post-Deployment](#post-deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

1. **Terraform** v1.13.4 or newer
2. **Terragrunt** v0.92.1 or newer
3. **AWS CLI** (for secret management and verification)
4. **Git** (for cloning the repository)

### AWS Account Setup

1. **AWS Account** with appropriate permissions
2. **IAM User** or **IAM Role** with permissions to create:
   - VPC and networking resources
   - RDS instances
   - ElastiCache clusters
   - EFS file systems
   - EC2 instances and Auto Scaling groups
   - Application Load Balancers
   - Security Groups
   - IAM roles and policies (for EC2 instances)

3. **S3 Bucket** for Terraform state (will be created automatically based on account ID)
4. **DynamoDB Table** for state locking (will be created automatically based on account ID)

## Pre-Deployment Checklist

### 1. Security Setup

- [ ] **NEVER use the example password** in production
- [ ] Generate strong, random passwords for databases
- [ ] Store secrets in AWS Secrets Manager:
  ```bash
  aws secretsmanager create-secret \
    --name magento/db/master-password \
    --secret-string '{"password":"YOUR_STRONG_RANDOM_PASSWORD"}' \
    --region ap-southeast-1
  ```
- [ ] Review and update `mysql/terragrunt.hcl` to use Secrets Manager
- [ ] Configure AWS credentials securely (environment variables or AWS profile)

### 2. Configuration Review

- [ ] Review and customize VPC CIDR in `magento_vpc/terragrunt.hcl`
- [ ] Review instance sizes and adjust for your needs:
  - RDS: `mysql/terragrunt.hcl` (default: db.m6g.2xlarge)
  - Redis: `elastic_cache/terragrunt.hcl`
  - EC2: `magento_auto_scaling/terragrunt.hcl`
- [ ] Review security group rules
- [ ] Set appropriate backup retention periods
- [ ] Configure multi-AZ if needed for production
- [ ] Review and set AWS region in `root.hcl` (default: ap-southeast-1)

### 3. Cost Estimation

Run AWS Cost Calculator or estimate based on:
- RDS instance size and hours
- ElastiCache node size and hours
- EC2 instance types and Auto Scaling configuration
- EFS storage (pay per GB)
- Data transfer costs
- ALB costs

**Tip**: Start with smaller instances for testing, then scale up.

## Deployment Steps

### Step 1: Clone Repository

```bash
git clone https://github.com/Genaker/TerraformMagentoCloud.git
cd TerraformMagentoCloud
```

### Step 2: Configure AWS Credentials

```bash
export AWS_DEFAULT_REGION=ap-southeast-1
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```

Or use AWS profile:
```bash
export AWS_PROFILE=your_profile_name
```

### Step 3: Initialize Backend (First Time Only)

The S3 bucket and DynamoDB table for state management should exist. If they don't, create them:

```bash
# Get your AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create S3 bucket for state
aws s3 mb s3://terraform-states-${ACCOUNT_ID} --region ap-southeast-1
aws s3api put-bucket-versioning \
  --bucket terraform-states-${ACCOUNT_ID} \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket terraform-states-${ACCOUNT_ID} \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks-${ACCOUNT_ID} \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-1
```

### Step 4: Review Infrastructure Plan

Navigate to the production directory and review what will be created:

```bash
cd magento-cloud-minimal/production
terragrunt run-all plan
```

Review the output carefully. This will show all resources that will be created.

### Step 5: Deploy Infrastructure

#### Option A: Deploy All Modules at Once (Recommended)

Terragrunt will automatically handle the dependency order:

```bash
cd magento-cloud-minimal/production
terragrunt run-all apply
```

When prompted, review the changes and type `yes` to confirm.

#### Option B: Deploy Modules Individually

Deploy modules in the correct order:

```bash
cd magento-cloud-minimal/production

# 1. Base data
cd aws-data && terragrunt apply && cd ..

# 2. VPC
cd magento_vpc && terragrunt apply && cd ..

# 3. Security groups
cd db_security && terragrunt apply && cd ..
cd redis_security && terragrunt apply && cd ..
cd web_nodes_security && terragrunt apply && cd ..
cd load_balancer_security && terragrunt apply && cd ..

# 4. Database
cd mysql && terragrunt apply && cd ..

# 5. Cache
cd elastic_cache && terragrunt apply && cd ..

# 6. File system
cd efs && terragrunt apply && cd ..

# 7. Load balancer
cd load_balancer && terragrunt apply && cd ..

# 8. Auto scaling
cd magento_auto_scaling && terragrunt apply && cd ..
```

### Step 6: Verify Deployment

```bash
# Check VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Magento_VPC"

# Check RDS instance
aws rds describe-db-instances --db-instance-identifier mysql

# Check ElastiCache
aws elasticache describe-cache-clusters

# Check ALB
aws elbv2 describe-load-balancers

# Check Auto Scaling group
aws autoscaling describe-auto-scaling-groups
```

## Post-Deployment

### 1. Save Important Information

Record these details:
- VPC ID
- RDS endpoint
- Redis endpoint
- EFS ID
- ALB DNS name
- Auto Scaling group name

Get outputs:
```bash
cd magento-cloud-minimal/production
terragrunt run-all output
```

### 2. Configure Application

1. Update Magento configuration with:
   - Database endpoint (from RDS)
   - Redis endpoint (from ElastiCache)
   - EFS mount point

2. Configure SSL/TLS certificates on ALB

3. Set up DNS records pointing to ALB

### 3. Security Hardening

- [ ] Rotate the database master password
- [ ] Enable AWS CloudTrail for audit logging
- [ ] Enable VPC Flow Logs
- [ ] Configure CloudWatch alarms for critical metrics
- [ ] Review and tighten security group rules
- [ ] Enable AWS GuardDuty for threat detection
- [ ] Configure AWS WAF on the ALB
- [ ] Enable AWS Config for compliance monitoring

### 4. Backup Configuration

- [ ] Verify RDS automated backups are enabled
- [ ] Configure EFS backup with AWS Backup
- [ ] Document backup retention policies
- [ ] Test backup restoration procedures

### 5. Monitoring Setup

Configure CloudWatch dashboards for:
- RDS performance metrics
- ElastiCache metrics
- EC2 instance metrics
- ALB metrics
- EFS metrics

Set up CloudWatch alarms for:
- RDS CPU utilization > 80%
- RDS storage space < 10%
- ALB 5xx errors > threshold
- EC2 instance health
- Auto Scaling events

### 6. Cost Optimization

- Review AWS Cost Explorer
- Set up AWS Budgets with alerts
- Consider Reserved Instances for predictable workloads
- Review and optimize Auto Scaling policies
- Use Graviton instances where possible (ARM64)

## Troubleshooting

### Issue: Terraform State Lock Timeout

**Cause**: Previous operation didn't release the lock or crashed.

**Solution**:
```bash
# List locks
aws dynamodb scan --table-name terraform-locks-ACCOUNT_ID

# If needed, manually remove stale lock (use with caution!)
aws dynamodb delete-item \
  --table-name terraform-locks-ACCOUNT_ID \
  --key '{"LockID": {"S": "path/to/state/terraform.tfstate-md5"}}'
```

### Issue: Insufficient IAM Permissions

**Cause**: IAM user/role lacks required permissions.

**Solution**: Ensure IAM policy includes all necessary permissions. See AWS documentation for required permissions for each service.

### Issue: Resource Already Exists

**Cause**: Resource with the same name already exists.

**Solution**: Either delete the existing resource or rename in configuration.

### Issue: RDS Instance Creation Timeout

**Cause**: RDS instances can take 10-15 minutes to create.

**Solution**: Be patient. Monitor progress in AWS Console.

### Issue: Auto Scaling Group Not Launching Instances

**Possible Causes**:
1. AMI not available in region
2. Instance type not available in availability zone
3. Security group rules blocking traffic
4. IAM instance profile missing

**Solution**: Check CloudWatch logs and EC2 Auto Scaling activity history.

### Issue: Cannot Connect to RDS

**Possible Causes**:
1. Security group not allowing traffic
2. RDS in wrong subnet (should be in database subnet)
3. Incorrect endpoint
4. Database not finished initializing

**Solution**: 
```bash
# Test from EC2 instance in same VPC
mysql -h YOUR_RDS_ENDPOINT -u USERNAME -p
```

## Rolling Back

If you need to destroy the infrastructure:

```bash
cd magento-cloud-minimal/production

# Destroy all resources (this will delete everything!)
terragrunt run-all destroy
```

**WARNING**: This will delete all data. Ensure backups are taken if needed.

## Getting Help

- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Review [AWS Documentation](https://docs.aws.amazon.com/)
- Check [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Open an issue on GitHub for bugs or questions

## Best Practices

1. **Always test in non-production first**
2. **Use version control** for all configuration changes
3. **Review plans** before applying
4. **Implement proper secrets management** (never commit secrets)
5. **Enable logging and monitoring** from day one
6. **Document changes** and maintain runbooks
7. **Regular security audits** and updates
8. **Test disaster recovery** procedures
9. **Use separate AWS accounts** for dev/staging/production
10. **Implement proper tagging** strategy for cost allocation

## Next Steps

- Set up CI/CD pipeline for application deployments
- Configure monitoring and alerting
- Implement disaster recovery procedures
- Plan for scaling and performance optimization
- Schedule regular security reviews
