locals {
  aws_region = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-efs.git?ref=1.8.0"
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
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.0.0?tab=inputs
###########################################################
inputs = {

  # Name of EFS
  # type: string
  name = "efs-magento"

  # ID of the VPC where to create EFS
  # type: string
  vpc_id = dependency.magento_vpc.outputs.vpc_id
  
  # ID element. Usually an abbreviation of your organization name,
  # e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique
  namespace = "efs"
  
  # ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'
  stage = "magento"
  
  # AWS Region	
  region = local.aws_region
  
  # VPS
  efs_vpc_id = dependency.magento_vpc.outputs.vpc_id
  
  # Subnets
  subnets = dependency.magento_vpc.outputs.public_subnets
  
  # Security Groups 
  security_groups = [dependency.web_nodes_security.outputs.security_group_id]
}

