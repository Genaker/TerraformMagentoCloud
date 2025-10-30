terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v4.0.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../magento_vpc"]
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/4.0.0?tab=inputs
###########################################################
inputs = {
  # List of IPv4 CIDR ranges to use on all ingress rules
  # type: list(string)
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # List of ingress rules to create by name
  # type: list(string)
  ingress_rules = ["all-all"]

  # Name of security group
  # type: string
  name = "Redis_Security"

  # ID of the VPC where to create security group
  # type: string
  vpc_id = dependency.magento_vpc.outputs.vpc_id

  
}
