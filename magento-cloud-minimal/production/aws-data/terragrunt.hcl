terraform {
  source = "${get_parent_terragrunt_dir()}/../../modules/aws-data"
}

include {
  path = find_in_parent_folders("root.hcl")
}


inputs = {
  use_localstack = tobool(get_env("USE_LOCALSTACK", "false"))
}
