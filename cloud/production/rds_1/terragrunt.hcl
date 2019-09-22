terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-rds.git?ref=v2.0.0"
}

include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../vpc", "../security-group_1"]
}

inputs = {
  # The allocated storage in gigabytes
  # type: string
  allocated_storage = "50"

  # The days to retain backups for
  # type: string
  backup_retention_period = "0"

  # The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window
  # type: string
  backup_window = ""

  # Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC
  # type: string
  db_subnet_group_name = "" # @tfvars:terraform_output.vpc.database_subnet_group

  # The database engine to use
  # type: string
  engine = "mysql"

  # The engine version to use
  # type: string
  engine_version = "5.7.19"

  # The family of the DB parameter group
  # type: string
  family = "mysql5.7"

  # The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier
  # type: string
  identifier = "mature-alien"

  # The instance type of the RDS instance
  # type: string
  instance_class = "db.m5.2xlarge"

  # The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'
  # type: string
  maintenance_window = ""

  # Specifies the major version of the engine that this option group should be associated with
  # type: string
  major_engine_version = "5.7"

  # Specifies if the RDS instance is multi-AZ
  # type: bool
  multi_az = false

  # Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file
  # type: string
  password = "gEGScAlS1qTH"

  # The port on which the DB accepts connections
  # type: string
  port = "3306"

  # Username for the master DB user
  # type: string
  username = "RDS Main"

  # List of VPC security groups to associate
  # type: list
  vpc_security_group_ids = [] # @tfvars:terraform_output.security-group_1.this_security_group_id.to_list

  
}
