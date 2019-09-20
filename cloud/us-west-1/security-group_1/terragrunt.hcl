terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-security-group.git?ref=v3.0.1"
}

#documentation - https://github.com/terraform-aws-modules/terraform-aws-security-group#security-group-with-custom-rules

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc"]
}

inputs = {
  # Name of security group
  # type: string
  name = "Security Grpup RDS"
  
  # ID of the VPC where to create security group
  # type: string
  vpc_id = "" # @tfvars:terraform_output.vpc.vpc_id

  description = "Security group for RDS"


  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3308
      protocol    = "tcp"
      description = "MySQL Acess"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "mysql-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "MySQL Acess Native"
    },
  ]

egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "All protocols"
    },
  ]


  
}
