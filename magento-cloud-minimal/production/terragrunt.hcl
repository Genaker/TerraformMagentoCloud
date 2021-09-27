locals {
  aws_region = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
}

terraform {
  extra_arguments "disable_input" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }
}

remote_state {
  backend      = "s3"
  disable_init = tobool(get_env("TERRAGRUNT_DISABLE_INIT", "false"))

  generate = {
    path      = "_backend.tf"
    if_exists = "overwrite"
  }

  config = {
    encrypt        = true
    region         = local.aws_region
    key            = format("%s/terraform.tfstate", path_relative_to_include())
    bucket         = format("terraform-statess-%s", get_aws_account_id())
    dynamodb_table = format("terraform-lockss-%s", get_aws_account_id())

    skip_metadata_api_check     = true
    skip_credentials_validation = false
  }
}

generate "main_providers" {
  path      = "main_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}
EOF
}
