terraform {
  source = "git::git@github.com:terraform-aws-modules/terraform-aws-s3-bucket.git?ref=v2.1.0"
}

include {
  path = find_in_parent_folders()
}

###########################################################
# View all available inputs for this module:
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/2.1.0?tab=inputs
###########################################################
inputs = {
  # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name.
  # type: string
  bucket = format("s3-bucket-magento-deployment-%s", get_aws_account_id()) 
}
