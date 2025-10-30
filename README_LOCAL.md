# Local Testing with Terragrunt + Terraform + LocalStack

This guide shows how to run plans/applies locally against LocalStack using a Docker image that contains Terraform and Terragrunt.

## ✅ Updated Versions (2025)
- **Terraform:** v1.13.4 (latest stable)
- **Terragrunt:** v0.92.1 (latest stable)  
- **AWS Provider:** v6.18.0 (auto-detected)
- **Go:** 1.24.9

## Prerequisites
1. Docker Desktop running
2. LocalStack (optional for local testing)
   - Default port: `4566`
   - If using a different port, update `LOCALSTACK_ENDPOINT`

## Quick Start

### 1. Build the Docker Image (once)

**Linux/macOS:**
```bash
cd /home/yehor/TerraformMagentoCloud
docker build -t tg-tf:local .
```

**Windows PowerShell:**
```powershell
cd C:\Users\<YOUR_USER>\TerraformMagentoCloud
docker build -t tg-tf:local .
```

### 2. Start LocalStack (for local testing)

```bash
docker run -d --name localstack -p 4566:4566 localstack/localstack:latest
```

Wait 10 seconds for LocalStack to initialize, then create the S3 bucket:
```bash
docker run --rm \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  --entrypoint aws \
  amazon/aws-cli \
  --endpoint-url=http://host.docker.internal:4566 \
  s3 mb s3://localstack-terraform-state
```

### 3. Test Infrastructure

**Linux/macOS - Set Environment Variables:**
```bash
export USE_LOCALSTACK=true
export LOCALSTACK_ENDPOINT=http://host.docker.internal:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=ap-southeast-1
export TG_NON_INTERACTIVE=true
```

**Windows PowerShell:**
```powershell
$env:USE_LOCALSTACK = "true"
$env:LOCALSTACK_ENDPOINT = "http://host.docker.internal:4566"
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "ap-southeast-1"
$env:TG_NON_INTERACTIVE = "true"
```

## Working with Individual Modules

### Validate a Module

**Linux/macOS:**
```bash
cd /home/yehor/TerraformMagentoCloud

docker run --rm \
  -v ${PWD}:/work \
  -w /work/magento-cloud-minimal/production/aws-data \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt validate --no-color"
```

**Windows PowerShell:**
```powershell
docker run --rm `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production/aws-data `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TG_NON_INTERACTIVE=$env:TG_NON_INTERACTIVE `
  tg-tf:local -lc "terragrunt validate --no-color"
```

### Plan a Module

**Linux/macOS:**
```bash
docker run --rm \
  -v ${PWD}:/work \
  -w /work/magento-cloud-minimal/production/aws-data \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt plan -lock=false --no-color"
```

**Windows PowerShell:**
```powershell
docker run --rm `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production/aws-data `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TG_NON_INTERACTIVE=$env:TG_NON_INTERACTIVE `
  tg-tf:local -lc "terragrunt plan -lock=false --no-color"
```

### Apply a Module

**Linux/macOS:**
```bash
docker run --rm \
  -v ${PWD}:/work \
  -w /work/magento-cloud-minimal/production/aws-data \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt apply -lock=false -auto-approve --no-color"
```

**Windows PowerShell:**
```powershell
docker run --rm `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production/aws-data `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TG_NON_INTERACTIVE=$env:TG_NON_INTERACTIVE `
  tg-tf:local -lc "terragrunt apply -lock=false -auto-approve --no-color"
```

## Deploy All Modules at Once

**Linux/macOS:**
```bash
cd /home/yehor/TerraformMagentoCloud/magento-cloud-minimal/production

# Validate all modules
docker run --rm \
  -v ${PWD}:/work \
  -w /work \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt run --all validate --no-color"

# Plan all modules (see what will be created)
docker run --rm \
  -v ${PWD}:/work \
  -w /work \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt run --all -- plan -lock=false --no-color"

# Apply all modules (create infrastructure)
docker run --rm \
  -v ${PWD}:/work \
  -w /work \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt run --all -- apply -lock=false -auto-approve --no-color"
```

**Windows PowerShell:**
```powershell
cd C:\Users\<YOUR_USER>\TerraformMagentoCloud\magento-cloud-minimal\production

# Apply all modules
docker run --rm `
  -v ${PWD}:/work `
  -w /work `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TG_NON_INTERACTIVE=$env:TG_NON_INTERACTIVE `
  tg-tf:local -lc "terragrunt run --all -- apply -lock=false -auto-approve --no-color"
```

## Module Deployment Order

The infrastructure has dependencies. Terragrunt automatically handles the order:

```
1. aws-data              # Base data sources
2. magento_vpc           # VPC and networking
3. db_security           # Database security group
4. redis_security        # Redis security group  
5. web_nodes_security    # Web nodes security group
6. load_balancer_security # ALB security group
7. mysql                 # RDS database
8. elastic_cache         # Redis cache
9. efs                   # Elastic File System
10. load_balancer        # Application Load Balancer
11. magento_auto_scaling # EC2 Auto Scaling Group
```

With `terragrunt run --all`, dependencies are automatically resolved in the correct order.

### Alternative: Using Terragrunt Shortcuts

According to the [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/reference/cli/commands/run/), you can also use shortcuts:

```bash
# These are equivalent:
terragrunt run --all -- plan
terragrunt plan --all

# These are equivalent:
terragrunt run --all -- apply -auto-approve
terragrunt apply --all -auto-approve

# These are equivalent:
terragrunt run --all -- destroy
terragrunt destroy --all
```

**Shortcut example for LocalStack:**
```bash
cd /home/yehor/TerraformMagentoCloud/magento-cloud-minimal/production

docker run --rm \
  -v ${PWD}:/work \
  -w /work \
  -e USE_LOCALSTACK=true \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  -e TG_NON_INTERACTIVE=true \
  --entrypoint /bin/sh \
  tg-tf:local -lc "terragrunt apply --all -lock=false -auto-approve --no-color"
```

## Deploy to Real AWS

When ready to deploy to real AWS (not LocalStack):

### Option 1: Deploy All Modules at Once (Recommended)

```bash
# Unset LocalStack variables
unset USE_LOCALSTACK
unset LOCALSTACK_ENDPOINT

# Set real AWS credentials
export AWS_ACCESS_KEY_ID=<your-real-key>
export AWS_SECRET_ACCESS_KEY=<your-real-secret>
export AWS_DEFAULT_REGION=ap-southeast-1

# Navigate to production directory
cd /home/yehor/TerraformMagentoCloud/magento-cloud-minimal/production

# Review what will be created (all modules)
terragrunt run --all -- plan

# Apply all modules (Terragrunt handles dependency order automatically)
terragrunt run --all -- apply

# Or using shortcut:
terragrunt apply --all
```

### Option 2: Deploy Modules Individually

```bash
# Navigate to production directory
cd /home/yehor/TerraformMagentoCloud/magento-cloud-minimal/production

# Review what will be created
cd aws-data && terragrunt plan
cd ../magento_vpc && terragrunt plan

# Apply when ready
cd ../aws-data && terragrunt apply
cd ../magento_vpc && terragrunt apply
# ... continue with other modules in dependency order
```

## Verify LocalStack Deployment

Check created resources:

```bash
# List VPCs
docker run --rm \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  --entrypoint aws \
  amazon/aws-cli \
  --endpoint-url=http://host.docker.internal:4566 \
  ec2 describe-vpcs

# Check Terraform state files
docker run --rm \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  --entrypoint aws \
  amazon/aws-cli \
  --endpoint-url=http://host.docker.internal:4566 \
  s3 ls s3://localstack-terraform-state/
```

## Terratest (Optional)

The tools image includes Go for running infrastructure tests:

**Linux/macOS:**
```bash
docker run --rm \
  -v ${PWD}:/work \
  -w /work/tests \
  --entrypoint /bin/sh \
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 \
  -e AWS_ACCESS_KEY_ID=test \
  -e AWS_SECRET_ACCESS_KEY=test \
  -e AWS_DEFAULT_REGION=ap-southeast-1 \
  tg-tf:local -lc "go test -v ./..."
```

**Windows PowerShell:**
```powershell
docker run --rm `
  -v ${PWD}:/work `
  -w /work/tests `
  --entrypoint /bin/sh `
  -e LOCALSTACK_ENDPOINT=http://host.docker.internal:4566 `
  -e AWS_ACCESS_KEY_ID=test `
  -e AWS_SECRET_ACCESS_KEY=test `
  -e AWS_DEFAULT_REGION=ap-southeast-1 `
  tg-tf:local -lc "go test -v ./..."
```

## Troubleshooting

### LocalStack Not Accessible
- Ensure LocalStack is running: `docker ps | grep localstack`
- Check LocalStack logs: `docker logs localstack`
- Verify port 4566 is accessible

### Git SSH Authentication Issues
✅ **Fixed!** All modules now use HTTPS Git URLs instead of SSH.

### State Lock Errors
Use `-lock=false` flag when testing with LocalStack:
```bash
terragrunt plan -lock=false
terragrunt apply -lock=false -auto-approve
```

### Provider Install Errors
The Docker image caches providers in `/tmp/tf-cache` to speed up operations.

### Module Source Errors
All module sources use HTTPS URLs (not SSH) for easier access without SSH keys.

## Clean Up LocalStack

Stop and remove LocalStack container:
```bash
docker stop localstack
docker rm localstack
```

Remove state bucket data:
```bash
docker volume prune
```

## Notes

- **Terragrunt v0.92.1** uses new CLI commands (no more `run-all`, use native Terraform commands)
- **State locking** with DynamoDB doesn't work perfectly in LocalStack, use `-lock=false`
- **LocalStack** mocks AWS services but may not support all features
- For **production deployment**, always use real AWS credentials and remove LocalStack flags

## Resources Created

When fully deployed, the infrastructure creates:
- 1 VPC with public/private/database subnets
- 4 Security Groups (DB, Redis, Web Nodes, Load Balancer)
- 1 RDS MariaDB instance
- 1 ElastiCache Redis cluster
- 1 EFS file system
- 1 Application Load Balancer
- 1 Auto Scaling Group for Magento instances

**Total Resources:** ~30-40 AWS resources
