locals {
  aws_region      = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
  use_localstack  = tobool(get_env("USE_LOCALSTACK", "false"))
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-efs.git?ref=v1.6.5"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../magento_vpc", "../web_nodes_security", "../aws-data"]
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

dependency "web_nodes_security" {
  config_path = "../web_nodes_security"
}

dependency "aws-data" {
  config_path = "../aws-data"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/efs/aws/latest?tab=inputs
###########################################################
inputs = {
  # Name of EFS file system
  name = "magento-efs"

  # Backup policy - disabled by default (set to true for production)
  enable_backup_policy = false

  # Mount targets configuration
  mount_targets = {
    # Note: In LocalStack, subnets may be empty. For production, configure proper subnets
    # Example format when subnets are available:
    # for subnet_id in dependency.magento_vpc.outputs.public_subnets :
    # subnet_id => {
    #   subnet_id = subnet_id
    # }
  }

  # Security group rules
  security_group_description = "EFS security group for Magento"
  security_group_vpc_id      = dependency.magento_vpc.outputs.vpc_id
  
  security_group_rules = {
    vpc = {
      description = "NFS ingress from VPC"
      cidr_blocks = [dependency.magento_vpc.outputs.vpc_cidr_block]
    }
  }

  # Tags
  tags = {
    Name        = "magento-efs"
    Environment = "production"
    Terraform   = "true"
  }
}

