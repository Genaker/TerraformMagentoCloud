locals {
  aws_region = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
}

terraform {
  source = "git::git@github.com:cloudposse/terraform-aws-efs.git?ref=0.31.1"
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
  
  namespace       = "efs"
  stage           = "magento"
  region          = local.aws_region
  efs_vpc_id      = dependency.magento_vpc.outputs.vpc_id
  subnets         = dependency.magento_vpc.outputs.public_subnets
  security_groups = [dependency.web_nodes_security.outputs.security_group_id]

  
}

