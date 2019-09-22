# Infrastructure code for Magento 2 Cloud Archetecture on AWS

This reposetory contains Magento 2 Cloud Terraform infrastructure as a code for AWS Public Cloud

##AWS Magento 2 Cloud Features:
* True Horizontal Auto Scaling 
* Affordabie(starting from ~300$ for us-west-2 region)
* MySQL RDS scalable Managed by Amazon, multi az failover
* EFS - Fully managed elastic NFS for media and configuration sharing
* CloudFront CDN
* Automatic Bakups - easy restore
* 99.9 Uptime, multi az high avalability 
* Hihg security 
* Redis cluster
* Different apllication scaling groups 
* Aplication Load Ballancer SSL termination 
* Scaled Varnish group
* Possibility to run the same infrastructure on Production/Staging/Dev environment, differnt projects
* Automatic CI/CD (CodePipeline/CodeDeploy) deployments possible

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


# Approximate Magento 2 AWS Cloud infrastructure Cost

```
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| Category    | Type                | Region    | Total cost | Count | Unit price | Instance type | Instance size |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| appservices | Email Service       | us-west-2 | $1.00      | 1     | $1.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| storage     | EFS storage – 20GB  | us-west-2 | $6.00      | 1     | $6.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| storage     | S3 – 50Gb           | us-west-2 | $2.00      | 1     | $2.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| compute     | ec2-Web Node        | us-west-2 | $61.20     | 1     | $61.20     | c5            | large         |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| networking  | elb                 | us-west-2 | $43.92     | 2     | $21.96     |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| compute     | ec2-Admin-Cron Node | us-west-2 | $29.95     | 1     | $29.95     | t3            | medium        |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| database    | ElastiCache-Redis   | us-west-2 | $24.48     | 1     | $24.48     | t3            | small         |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| compute     | ec2-Varnish         | us-west-2 | $29.95     | 1     | $29.95     | t3            | large         |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| analytics   | ElasticSearch       | us-west-2 | $12.96     | 1     | $12.96     | t2            | micro         |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| database    | RDS MySQL           | us-west-2 | $48.96     | 1     | $48.96     | t3            | medium        |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| storage     | EBS Storage 30Gb    | us-west-2 | $9.13      | 1     | $9.13      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
|             |                     | Total     | $269.55    |       |            |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
```


