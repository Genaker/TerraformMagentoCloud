# Minimal Magento Cloud Infrastructure 

![Minimal Magento Cloud Infrastructure](https://user-images.githubusercontent.com/9213670/134857584-7771a2ec-73d1-45d0-858f-d628c13e21b9.png)

## Quick start

1. [Install Terraform 0.15 or newer](https://learn.hashicorp.com/tutorials/terraform/install-cli)
1. [Install Terragrunt 0.29 or newer](https://terragrunt.gruntwork.io/docs/getting-started/install/)
1. Optionally, [install pre-commit hooks](https://pre-commit.com/#install) to keep Terraform formatting and documentation up-to-date.

If you are using macOS you can install all dependencies using [Homebrew](https://brew.sh/):

    $ brew install terraform terragrunt pre-commit

## Configure access to AWS account

The recommended way to configure access credentials to AWS account is using environment variables:

```
$ export AWS_DEFAULT_REGION=ap-southeast-1
$ export AWS_ACCESS_KEY_ID=...
$ export AWS_SECRET_ACCESS_KEY=...
```

Alternatively, you can edit `terragrunt.hcl` and use another authentication mechanism as described in [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication).

## Create and manage your infrastructure

Infrastructure consists of multiple layers (magento_auto_scaling, mysql, load_balancer, ...) where each layer is described using one [Terraform module](https://www.terraform.io/docs/configuration/modules.html) with `inputs` arguments specified in `terragrunt.hcl` in respective layer's directory.

Navigate through layers to review and customize values inside `inputs` block.

There are two ways to manage infrastructure (slower&complete, or faster&granular):
- **Region as a whole (slower&complete).** Run this command to create infrastructure in all layers in a single region:

```
$ cd ap-southeast-1
$ terragrunt run-all apply
```

- **As a single layer (faster&granular).** Run this command to create infrastructure in a single layer (eg, `magento_auto_scaling`):

```
$ cd ap-southeast-1/magento_auto_scaling
$ terragrunt apply
```

After the confirmation your infrastructure should be created.


## References

* [Terraform documentation](https://www.terraform.io/docs/) and [Terragrunt documentation](https://terragrunt.gruntwork.io/docs/) for all available commands and features
* [Terraform AWS modules](https://github.com/terraform-aws-modules/)
* [Terraform modules registry](https://registry.terraform.io/)
* [Terraform best practices](https://www.terraform-best-practices.com/)


