terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-autoscaling.git?ref=v9.0.2"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../aws-data", "../magento_vpc", "../web_nodes_security", "../load_balancer"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

dependency "web_nodes_security" {
  config_path = "../web_nodes_security"
}


dependency "load_balancer" {
  config_path = "../load_balancer"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/4.1.0?tab=inputs
###########################################################
inputs = {
  # Determines whether to create launch template or not
  # type: bool
  create_lt = true

  # The number of Amazon EC2 instances that should be running in the autoscaling group
  # type: number
  desired_capacity = 1

  # `EC2` or `ELB`. Controls how health checking is done
  # type: string
  health_check_type = "EC2"

  # The AMI from which to launch the instance
  # type: string
  image_id = dependency.aws-data.outputs.amazon_linux2_aws_ami_id

  # The type of the instance to launch
  # type: string
  instance_type = "c6g.large"
  
  #load_balancers = dependency.load_balancer.outputs.load_balancer_id

  # The maximum size of the autoscaling group
  # type: number
  max_size = 1

  # The minimum size of the autoscaling group
  # type: number
  min_size = 0

  # Name used across the resources created
  # type: string
  name = "Magento_Auto_Scaling"

  # A list of security group IDs to associate
  # type: list(string)
  security_groups = [dependency.web_nodes_security.outputs.security_group_id]

  # Determines whether to use a launch template in the autoscaling group or not
  # type: bool
  use_lt = true

  # A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones`
  # type: list(string)
  vpc_zone_identifier = dependency.magento_vpc.outputs.public_subnets

  
}
