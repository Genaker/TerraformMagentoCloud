# Infrastructure code for Magento 2 Cloud AWS

This directory contains Magento 2 Cloud Terraform infrastructure as a code

Infrastructure consists of multiple layers (autoscaling_3, autoscaling_2, alb_2, ...) where each layer is configured using one of [Terraform AWS modules](https://github.com/terraform-aws-modules/) with arguments specified in `terraform.tfvars` in layer's directory.

Terraform use the SSH protocol to clone the modules, configured SSH keys will be used automatically. Add SSH key to github account. (https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account)

Terraform uses this during the module installation step of terraform init to download the source code to a directory on local disk so that it can be used by other Terraform commands.

[Terragrunt](https://github.com/gruntwork-io/terragrunt) is used to work with Terraform configurations which allows to orchestrate dependent layers, update arguments dynamically and keep configurations [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

![Magento 2 AWS Infrastructure Cloud ](https://github.com/Genaker/TerraformMagentoCloud/blob/master/Magento2Cloud.png)

## Pre-requirements

- [Terraform 0.12 or newer](https://www.terraform.io/)
- [Terragrunt 0.19 or newer](https://github.com/gruntwork-io/terragrunt)
- [tfvars-annotations](https://github.com/antonbabenko/tfvars-annotations) - Update values in terraform.tfvars using annotations
- Optional: [pre-commit hooks](http://pre-commit.com) to keep Terraform formatting and documentation up-to-date

If you are using Mac you can install all dependencies using Homebrew:

    $ brew install terraform terragrunt pre-commit

By default, access credentials to AWS account should be set using environment variables:

    $ export AWS_DEFAULT_REGION=us-west-1
    $ export AWS_ACCESS_KEY_ID=...
    $ export AWS_SECRET_ACCESS_KEY=...

Alternatively, you can edit `common/main_providers.tf` and use another authentication mechanism as described in [AWS provider documentation](https://www.terraform.io/docs/providers/aws/index.html#authentication).


## How to use it?

First, you should run `chmod +x common/scripts/update_dynamic_values_in_tfvars.sh`, review and specify all required arguments for each layer. Run this to see all errors:

    $ terragrunt validate-all --terragrunt-ignore-dependency-errors |& grep -C 3 "Error: "

Once all arguments are set, run this command to create infrastructure in all layers in a single region:

    $ cd us-west-1
    $ terragrunt apply-all

Alternatively, you can create infrastructure in a single layer (eg, `autoscaling_3`):

    $ cd us-west-1/autoscaling_3
    $ terragrunt apply

See [official Terragrunt documentation](https://github.com/gruntwork-io/terragrunt/blob/master/README.md) for all available commands and features.


