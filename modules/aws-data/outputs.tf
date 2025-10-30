output "aws_region" {
  description = "Details about selected AWS region"
  value       = var.use_localstack ? {
    name               = var.use_localstack ? (var.use_localstack ? "ap-southeast-1" : null) : null
    description        = "mocked for localstack"
    current            = true
    name_prefix_filter = null
    id                 = var.use_localstack ? "ap-southeast-1" : null
  } : data.aws_region.selected
}

output "available_aws_availability_zones_names" {
  description = "A list of the Availability Zone names available to the account"
  value       = var.use_localstack ? [] : data.aws_availability_zones.available.names
}

output "available_aws_availability_zones_zone_ids" {
  description = "A list of the Availability Zone IDs available to the account"
  value       = var.use_localstack ? [] : data.aws_availability_zones.available.zone_ids
}

output "amazon_linux2_aws_ami_id" {
  description = "AMI ID of Amazon Linux 2"
  value       = var.use_localstack ? "ami-00000000000000000" : data.aws_ami.amazon_linux2.id
}

#output "ubuntu_1804_aws_ami_id" {
#  description = "AMI ID of Ubuntu 18.04"
#  value       = data.aws_ami.ubuntu_1804.id
#}
