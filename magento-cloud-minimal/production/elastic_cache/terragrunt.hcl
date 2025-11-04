locals {
  aws_region      = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
  use_localstack  = tobool(get_env("USE_LOCALSTACK", "false"))
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-elasticache.git?ref=v1.9.0"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../magento_vpc", "../redis_security"]
}

dependency "magento_vpc" {
  config_path = "../magento_vpc"
}

dependency "redis_security" {
  config_path = "../redis_security"
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/elasticache/aws/latest
###########################################################
inputs = {
  # Cluster settings
  cluster_id              = "magento-redis"
  replication_group_id    = "magento-redis"
  engine                  = "redis"
  engine_version          = "6.x"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  parameter_group_name    = "default.redis6.x"
  
  # Network settings
  subnet_ids = dependency.magento_vpc.outputs.public_subnets
  security_group_ids = [dependency.redis_security.outputs.security_group_id]
  
  # Apply changes immediately	
  apply_immediately = true
  
  # Automatic failover (Not available for T1/T2 instances)	
  automatic_failover_enabled = false
  
  # Encryption settings
  # For production with transit_encryption_enabled=true:
  # - Set transit_encryption_enabled = true
  # - Set auth_token = "your-secure-token-here"
  at_rest_encryption_enabled = false
  transit_encryption_enabled = false
  
  # Tags
  tags = {
    Name        = "Magento-Redis"
    Environment = "production"
    Terraform   = "true"
  }
}
