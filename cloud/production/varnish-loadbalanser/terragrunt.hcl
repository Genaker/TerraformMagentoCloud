terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-alb.git?ref=v5.1.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../magento-cloud", "../loadbalancer-internet-securitygroup"]
}

dependency "magento-cloud" {
  config_path = "../magento-cloud"
}

dependency "loadbalancer-internet-securitygroup" {
  config_path = "../loadbalancer-internet-securitygroup"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/5.1.0?tab=inputs
###########################################################
inputs = {
  # The resource name and Name tag of the load balancer.
  # type: string
  name = "Varnish-ALB"

   # Controls if the ALB will log requests to S3.
  # type: bool
  logging_enabled = false

  # The security groups to attach to the load balancer. e.g. ["sg-edcd9784","sg-edcd9785"]
  # type: list(string)
  security_groups = [dependency.loadbalancer-internet-securitygroup.outputs.this_security_group_id]

  # A list of subnets to associate with the load balancer. e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']
  # type: list(string)
  subnets = dependency.magento-cloud.outputs.public_subnets

  # VPC id where the load balancer and other resources will be deployed.
  # type: string
  vpc_id = dependency.magento-cloud.outputs.vpc_id
}
