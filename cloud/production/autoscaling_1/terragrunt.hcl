terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-autoscaling.git?ref=v3.0.0"
}

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc", "../security-group_2", "../alb_1"]
}

inputs = {
  # The number of Amazon EC2 instances that should be running in the group
  # type: string
  desired_capacity = "1"

  # Controls how health checking is done. Values are - EC2 and ELB
  # type: string
  health_check_type = "EC2"

  # The EC2 image ID to launch
  # type: string
	##Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
  image_id = "ami-0b37e9efc396e4c38"

  # The size of instance to launch
  # type: string
  instance_type = "r5.large"

  # The maximum size of the auto scale group
  # type: string
  max_size = "1"

  # The minimum size of the auto scale group
  # type: string
  min_size = "1"

  # Creates a unique name beginning with the specified prefix
  # type: string
  name = "Varnish Auto Scaling"

  # A list of security group IDs to assign to the launch configuration
  # type: list
  security_groups = [] # @tfvars:terraform_output.security-group_2.this_security_group_id.to_list

  # A list of aws_alb_target_group ARNs, for use with Application Load Balancing
  # type: list
  target_group_arns = [] # @tfvars:terraform_output.alb_1.target_group_arns

  # A list of subnet IDs to launch resources in
  # type: list
  vpc_zone_identifier = [] # @tfvars:terraform_output.vpc.public_subnets

  
}
