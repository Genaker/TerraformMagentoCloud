terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-ec2-instance.git?ref=v2.17.0"
}

include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../aws-data", "../my_security", "../magento_vpc"]
}

dependency "aws-data" {
  config_path = "../aws-data"
}

dependency "my_security" {
  config_path = "../my_security"
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

locals {
  user_data = <<-EOT
  #!/bin/bash
  echo "Hello Terraform!"
  sleep 30
  echo "Install Elastic Search"

  wget https://raw.githubusercontent.com/Genaker/Magento-AWS-Linux-2-Installation/master/install-elastic-search.sh
  sudo bash ./install-elastic-search.sh
  EOT

  tags = {
    Role = "ElasticSearch"
  }
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/2.17.0?tab=inputs
###########################################################
inputs = {
  # ID of AMI to use for the instance
  # type: string
  ami = dependency.aws-data.outputs.amazon_linux2_aws_ami_id

  # The type of instance to start
  # type: string
  instance_type = "m6g.large"
  
  # List of VPC security groups to associate
  # type: list(string)
  vpc_security_group_ids = [dependency.my_security.outputs.security_group_id]

  subnet_ids = dependency.magento_vpc.outputs.public_subnets
  
  # Name to be used on all resources as prefix
  # type: string
  name = "EC2"

  # The cloud-init output log file (/var/log/cloud-init-output.log) captures console output 
  # so it is easy to debug your scripts following a launch if the instance does not behave the way you intended.
  user_data_base64 = base64encode(local.user_data)
  
  tags = local.tags
}


# Test instance : curl $IP:9200
