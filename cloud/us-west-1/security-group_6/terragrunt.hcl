terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v3.0.1"
}

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  # Name of security group
  # type: string
  name = "Web Node ELB"

  # ID of the VPC where to create security group
  # type: string
  vpc_id = "" # @tfvars:terraform_output.vpc.vpc_id

  
}
