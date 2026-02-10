#!/bin/bash
# Install script for Terraform and Terragrunt
# Updated versions (2025) to match Dockerfile

set -e

export TERRAFORM_VERSION=1.13.4
export TERRAGRUNT_VERSION=0.92.1

echo "Installing Terraform ${TERRAFORM_VERSION}..."
mkdir -p /tmp/terraform_${TERRAFORM_VERSION}
wget -nv -O /tmp/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip /tmp/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /tmp/terraform_${TERRAFORM_VERSION}/
sudo chmod a+x /tmp/terraform_${TERRAFORM_VERSION}/terraform
sudo cp /tmp/terraform_${TERRAFORM_VERSION}/terraform /usr/local/bin/

echo "Installing Terragrunt ${TERRAGRUNT_VERSION}..."
mkdir -p /tmp/terragrunt_${TERRAGRUNT_VERSION}/
wget -nv -O /tmp/terragrunt_${TERRAGRUNT_VERSION}/terragrunt \
  https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64
sudo chmod a+x /tmp/terragrunt_${TERRAGRUNT_VERSION}/terragrunt
sudo cp /tmp/terragrunt_${TERRAGRUNT_VERSION}/terragrunt /usr/local/bin/

echo "Cleaning up..."
rm -rf /tmp/terraform_${TERRAFORM_VERSION} /tmp/terragrunt_${TERRAGRUNT_VERSION}

echo "Installation complete!"
terraform version
terragrunt --version
