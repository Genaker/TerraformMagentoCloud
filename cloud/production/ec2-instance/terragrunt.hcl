terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v2.3.0"
}

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  # ID of AMI to use for the instance
  # type: string
 ## ami-0b37e9efc396e4c38
  ami = "ami-0b37e9efc396e4c38"

  # The type of instance to start
  # type: string
  instance_type = "t2.micro"

  # Name to be used on all resources as prefix
  # type: string
  name = "Proxy Instance"

  # The VPC Subnet ID to launch in
  # type: string
  subnet_id = "" # @tfvars:terraform_output.vpc.vpc_id

  # A list of security group IDs to associate with
  # type: list
  vpc_security_group_ids = [] 

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  
}
