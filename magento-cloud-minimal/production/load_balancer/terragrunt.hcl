terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=v9.11.0"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../magento_vpc", "../load_balancer_security"]
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

dependency "load_balancer_security" {
  config_path = "../load_balancer_security"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/6.0.0?tab=inputs
###########################################################
inputs = {
  # The resource name and Name tag of the load balancer.
  # type: string
  name = "Magento-Load-Balancer"
  
  logging_enabled = false
   
  # A list of subnet IDs to attach to the ELB
  subnets = dependency.magento_vpc.outputs.public_subnets
  
  # If true, ELB will be an internal ELB
  internal = false
  
  # A list of security group IDs to assign to the ELB
  security_groups = [dependency.load_balancer_security.outputs.security_group_id]
  
  # AWS VPC
  vpc_id = dependency.magento_vpc.outputs.vpc_id
  
  # A list of listener blocks	
  listener = [
    {
      instance_port = 80
      instance_protocol = "HTTP"
      lb_port = 80
      lb_protocol = "HTTP"
    }
    #,
    #{
    #  instance_port     = 443
    #  instance_protocol = "http"
    #  lb_port           = 443
    #  lb_protocol       = "http"
    # ssl_certificate_id = "arn:aws:acm:eu-west-1:235367859451:certificate/6c270328-2cd5-4b2d-8dfd-ae8d0004ad31"
    #},
  ]
  
  # health_check = {
  #  target              = "HTTP:80/"
  #  interval            = 30
  #  healthy_threshold   = 2
  #  unhealthy_threshold = 2
  #  timeout             = 5
  #}
}
