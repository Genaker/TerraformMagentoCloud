terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-alb.git?ref=v4.0.0"
}

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc", "../security-group_6"]
}

inputs = {
  # The resource name and Name tag of the load balancer.
  # type: string
  load_balancer_name = "Web Nodes Load Balancer"

  # Controls if the ALB will log requests to S3.
  # type: bool
  logging_enabled = false

  # The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"]
  # type: list
  security_groups = [] # @tfvars:terraform_output.security-group_6.this_security_group_id.to_list

  # A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']
  # type: list
  subnets = [] # @tfvars:terraform_output.vpc.public_subnets

  # VPC id where the load balancer and other resources will be deployed.
  # type: string
  vpc_id = "" # @tfvars:terraform_output.vpc.vpc_id

  
}
