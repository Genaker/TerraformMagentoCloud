terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-autoscaling.git?ref=v3.4.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../aws-data", "../magento-cloud", "../varnishnode-securitygroup", "../varnish-loadbalanser"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

dependency "magento-cloud" {
  config_path = "../magento-cloud"
}

dependency "varnishnode-securitygroup" {
  config_path = "../varnishnode-securitygroup"
}

dependency "varnish-loadbalanser" {
  config_path = "../varnish-loadbalanser"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/autoscaling/aws/3.4.0?tab=inputs
###########################################################
inputs = {
  # The number of Amazon EC2 instances that should be running in the group
  # type: string
  desired_capacity = "1"

  # Controls how health checking is done. Values are - EC2 and ELB
  # type: string
  health_check_type = "EC2"

  # The EC2 image ID to launch
  # type: string
  image_id = dependency.aws-data.outputs.amazon_linux2_aws_ami_id

  # The size of instance to launch
  # type: string
  instance_type = "r5.large"

  # The maximum size of the auto scale group
  # type: string
  max_size = "1"

  # The minimum size of the auto scale group
  # type: string
  min_size = "0"

  # Creates a unique name beginning with the specified prefix
  # type: string
  name = "VarnishCacheProxyNode-ASG"

  # A list of security group IDs to assign to the launch configuration
  # type: list(string)
  security_groups = [dependency.varnishnode-securitygroup.outputs.this_security_group_id]

  # A list of aws_alb_target_group ARNs, for use with Application Load Balancing
  # type: list(string)
  target_group_arns = dependency.varnish-loadbalanser.outputs.target_group_arns

  # A list of subnet IDs to launch resources in
  # type: list(string)
  vpc_zone_identifier = dependency.magento-cloud.outputs.public_subnets

  
}
