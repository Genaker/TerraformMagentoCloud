# Contributing to TerraformMagentoCloud

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other community members

## Getting Started

### Prerequisites

1. **Required Tools**:
   - Docker Desktop (recommended) OR
   - Terraform v1.13.4+
   - Terragrunt v0.92.1+
   - Go 1.22+ (for testing)

2. **Optional Tools**:
   - pre-commit for automated checks
   - LocalStack for local testing
   - terraform-docs for documentation generation
   - tfsec or Checkov for security scanning

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/TerraformMagentoCloud.git
   cd TerraformMagentoCloud
   ```

3. Build the Docker image (recommended):
   ```bash
   docker build -t tg-tf:local .
   ```

4. (Optional) Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the coding standards below

3. Test your changes locally (see [Testing](#testing) section)

4. Commit your changes with clear, descriptive messages:
   ```bash
   git commit -m "Add feature: description of what was added"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Open a Pull Request

## Coding Standards

### Terraform Code Style

1. **Formatting**: Always format Terraform code:
   ```bash
   terraform fmt -recursive .
   ```

2. **Naming Conventions**:
   - Use lowercase with underscores for resource names: `my_resource_name`
   - Use descriptive names that indicate the resource purpose
   - Prefix security groups with their purpose: `db_security`, `web_security`

3. **Variable Definitions**:
   - Always include descriptions for variables
   - Specify types explicitly
   - Provide sensible defaults when appropriate
   - Document any constraints or validation rules

4. **Comments**:
   - Add comments for complex logic or non-obvious configurations
   - Link to relevant documentation for module inputs
   - Explain "why" rather than "what" when the code is not self-explanatory

### Terragrunt Configuration

1. **Module Sources**: Use versioned module sources with HTTPS URLs:
   ```hcl
   source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.16.0"
   ```

2. **Dependencies**: Clearly declare dependencies between modules:
   ```hcl
   dependencies {
     paths = ["../dependency-module"]
   }
   ```

3. **Documentation**: Add comments referencing module documentation:
   ```hcl
   # View all available inputs:
   # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
   ```

### Security Guidelines

1. **Secrets**: Never commit sensitive data:
   - No passwords, API keys, or credentials
   - Use placeholder values or references to secret management systems
   - Add examples in documentation for how to properly handle secrets

2. **Default Values**: Use secure defaults:
   - Enable encryption by default
   - Use private subnets for databases
   - Enable logging and monitoring

3. **Security Groups**: Follow the principle of least privilege:
   - Only open necessary ports
   - Use specific CIDR blocks, avoid 0.0.0.0/0 when possible
   - Document why each rule is needed

## Testing

### Local Testing with LocalStack

1. Start LocalStack:
   ```bash
   docker run -d --name localstack -p 4566:4566 localstack/localstack:latest
   ```

2. Set environment variables:
   ```bash
   export USE_LOCALSTACK=true
   export LOCALSTACK_ENDPOINT=http://host.docker.internal:4566
   export AWS_ACCESS_KEY_ID=test
   export AWS_SECRET_ACCESS_KEY=test
   export AWS_DEFAULT_REGION=ap-southeast-1
   ```

3. Test a module:
   ```bash
   cd magento-cloud-minimal/production/aws-data
   terragrunt init
   terragrunt plan -lock=false
   ```

### Automated Tests

Run the Go-based integration tests:

```bash
cd tests
go test -v ./...
```

### Validation Checks

Before submitting a PR, run these checks:

1. **Format check**:
   ```bash
   terraform fmt -check -recursive .
   ```

2. **Validation**:
   ```bash
   cd magento-cloud-minimal/production
   terragrunt run-all validate
   ```

3. **Security scanning** (recommended):
   ```bash
   # Using tfsec
   docker run --rm -v $(pwd):/src aquasec/tfsec /src
   
   # Using Checkov
   docker run --rm -v $(pwd):/tf bridgecrew/checkov -d /tf
   ```

## Submitting Changes

### Pull Request Guidelines

1. **Title**: Use a clear, descriptive title
   - Good: "Add support for multi-AZ RDS deployment"
   - Bad: "Update mysql config"

2. **Description**: Include:
   - What changes were made and why
   - Any breaking changes
   - Testing performed
   - Related issues (if any)

3. **Size**: Keep PRs focused and reasonably sized
   - Split large changes into multiple PRs when possible
   - Each PR should address a single concern

4. **Documentation**: Update relevant documentation:
   - README.md for user-facing changes
   - Module documentation for infrastructure changes
   - Code comments for complex logic

### Review Process

1. All PRs require at least one review
2. Address review feedback promptly
3. Keep discussions professional and constructive
4. CI checks must pass before merging

## Questions or Need Help?

- Open an issue for bugs or feature requests
- Use discussions for questions or general help
- Check existing issues and discussions first

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
