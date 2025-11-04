locals {
  aws_region          = get_env("AWS_DEFAULT_REGION", "ap-southeast-1")
  use_localstack      = tobool(get_env("USE_LOCALSTACK", "false"))
  localstack_endpoint = get_env("LOCALSTACK_ENDPOINT", "http://localhost:4566")

  # When USE_LOCALSTACK=true, generate an endpoints block for the AWS provider.
  aws_endpoints_block = local.use_localstack ? format(<<EOT
  endpoints {
    s3          = "%s"
    dynamodb    = "%s"
    ec2         = "%s"
    iam         = "%s"
    sts         = "%s"
    elbv2       = "%s"
    elasticache = "%s"
    efs         = "%s"
    rds         = "%s"
    route53     = "%s"
    autoscaling = "%s"
    cloudwatch  = "%s"
  }
EOT
,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint,
  local.localstack_endpoint) : ""

  # Only force path-style S3 addressing when using LocalStack
  aws_s3_path_style = local.use_localstack ? "s3_use_path_style = true" : ""
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

  config = merge(
    {
      encrypt        = true
      region         = local.aws_region
      key            = format("%s/terraform.tfstate", path_relative_to_include())
      bucket         = local.use_localstack ? "localstack-terraform-state" : format("terraform-states-%s", get_aws_account_id())
      dynamodb_table = local.use_localstack ? "localstack-terraform-locks" : format("terraform-locks-%s", get_aws_account_id())

      skip_metadata_api_check     = true
      skip_credentials_validation = local.use_localstack
      skip_requesting_account_id  = local.use_localstack
    },
    local.use_localstack ? {
      endpoint                    = local.localstack_endpoint
      force_path_style            = true
      skip_s3_checksum            = true
    } : {}
  )
}

generate "main_providers" {
  path      = "main_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = ${local.use_localstack}
  skip_requesting_account_id  = ${local.use_localstack}

  ${local.aws_s3_path_style}
  ${local.aws_endpoints_block}
}
EOF
}
