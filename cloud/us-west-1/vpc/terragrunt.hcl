terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-vpc.git?ref=v2.6.0"
}

include {
  path = "${find_in_parent_folders()}"
}



inputs = {
  # A list of availability zones in the region
  # type: list
  azs = ["us-west-2c","us-west-2a","us-west-2d"]

  # The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden
  # type: string
  cidr = "102.10.0.0/16"
 
  # private_subnets     = ["102.10.1.0/24", "102.10.2.0/24", "102.10.3.0/24"]
  # A list of public subnets inside the VPC
  # type: list
  public_subnets      = ["102.10.11.0/24", "102.10.12.0/24", "102.10.13.0/24"]
  # A list of database subnet
  # type: list
  #database_subnets    = ["102.10.21.0/24", "102.10.22.0/24", "102.10.23.0/24"]
  #elasticache_subnets = ["102.10.31.0/24", "102.10.32.0/24", "102.10.33.0/24"]
  #redshift_subnets    = ["102.10.41.0/24", "102.10.42.0/24", "102.10.43.0/24"]
  #intra_subnets       = ["102.10.51.0/24", "102.10.52.0/24", "102.10.53.0/24"]

  # Name to be used on all the resources as identifier
  # type: string
  name = "Preproduction-VPC"

 tags = {
    Name        = "Preproduction VPC"
    Environment = "Preproduction"
  }

}
