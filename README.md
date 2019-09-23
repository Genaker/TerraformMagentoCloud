# Infrastructure code for Magento 2 Cloud Archetecture on AWS

This reposetory contains Magento 2 Cloud Terraform infrastructure as a code for AWS Public Cloud

## AWS Magento 2 Cloud Features:
* True Horizontal Auto Scaling 
* Affordabie(starting from ~300$ for us-west-2 region)
* MySQL RDS scalable Managed by Amazon, multi az failover
* EFS - Fully managed elastic NFS for media and configuration sharing
* CloudFront CDN
* Automatic Bakups - easy restore
* 99.9 Uptime, multi az high avalability 
* Hihg security 
* Redis cluster
* Different apllication scaling groups (ASG)
* Aplication Load Ballancer SSL termination 
* Scaled Varnish group
* Dedicated Admin/Cron ASG
* You can easly add new autoscaling groups for you needs (Per WebSite/for Checkout requests/for API)  
* Possibility to run the same infrastructure on Production/Staging/Dev environment, differnt projects
* Automatic CI/CD (CodePipeline/CodeDeploy) deployments possible

![Magento 2 AWS Infrastructure Cloud ](https://github.com/Genaker/TerraformMagentoCloud/blob/master/Magento2Cloud.png)

Infrastructure consists of multiple layers (autoscaling_3, autoscaling_2, alb_2, ...) where each layer is configured using one of [Terraform AWS modules](https://github.com/terraform-aws-modules/) with arguments specified in `terraform.tfvars` in layer's directory.

Terraform use the SSH protocol to clone the modules, configured SSH keys will be used automatically. Add SSH key to github account. (https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account)

Terraform uses this during the module installation step of terraform init to download the source code to a directory on local disk so that it can be used by other Terraform commands.

[Terragrunt](https://github.com/gruntwork-io/terragrunt) is used to work with Terraform configurations which allows to orchestrate dependent layers, update arguments dynamically and keep configurations [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

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

    $ cd production
    $ terragrunt apply-all

Alternatively, you can create infrastructure in a single layer (eg, `autoscaling_3`):

    $ cd production/autoscaling_3
    $ terragrunt apply

See [official Terragrunt documentation](https://github.com/gruntwork-io/terragrunt/blob/master/README.md) for all available commands and features.


# Approximate Magento 2 AWS Cloud infrastructure Cost

```
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| Category    | Type                | Region    | Total cost | Count | Unit price | Instance type | Instance size |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| appservices | Email Service - 10K | us-west-2 | $1.00      | 1     | $1.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| storage     | EFS storage – 20GB  | us-west-2 | $6.00      | 1     | $6.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| storage     | S3 – 50Gb           | us-west-2 | $2.00      | 1     | $2.00      |               |               |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| compute     | ec2-Web Node        | us-west-2 | $61.20     | 1     | $61.20     | c5            | large         |
+-------------+---------------------+-----------+------------+-------+------------+---------------+---------------+
| networking  | elb - Load Balancer | us-west-2 | $43.92     | 2     | $21.96     |               |               |
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
# Basic Deployment With CodeDeploy Example 

ASSUMING YOU ALREADY HAVE an AWS account and CodeDeploy setup

Here are the basic that we take on a deployment for M2 

Here is the appspec.yml file (https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html#appspec-reference-ecs)
```
version: 0.0
os: linux
hooks:
    BeforeInstall:
        - location: config_files/scripts/beforeInstall.bash
          runas: root
    AfterInstall:
        - location: config_files/scripts/afterInstall.bash
          runas: mage_user
        - location: config_files/scripts/moveToProduction.bash
          runas: root
        - location: config_files/scripts/cacheclean.bash
          runas: mage_user
```

Script to 'compile' magento on Deploy server - You pull and compile code to a deploy server or build Docker container end after just push code to production fith Code Deploy - fastest way 

```
cd production/build/public_html
git checkout .
git pull origin master
rm -rf var/cache/* var/page_cache/* var/composer_home/* var/tmp/*
php composer.phar update --no-interaction --no-progress --optimize-autoloader
bin/magento setup:upgrade
bin/magento setup:static-content:deploy -t Magento/backend
bin/magento setup:static-content:deploy en_US es_ES -a frontend
bin/magento setup:di:compile
# Make code files and directories read-only
echo "Setting directory base permissions to 0750"
find . -type d -exec chmod 0750 {} \;
echo "Setting file base permissions to 0640"
find . -type f -exec chmod 0640 {} \;
chmod o-rwx app/etc/env.php && chmod u+x bin/magento

# Compress source at shared directory
if [ ! -d /build ]; then
    mkdir -p /build
fi
tar -czvf /build/build.tar.gz . --exclude='./pub/media' --exclude='./.htaccess' --exclude='./.git' --exclude='./var/cache' --exclude='./var/composer_home' --exclude='./var/log' --exclude='./var/page_cache' --exclude='./var/import' --exclude='./var/export' --exclude='./var/report' --exclude='./var/backups' --exclude='./var/tmp' --exclude='./var/resource_config.json' --exclude='./var/.sample-data-state.flag' --exclude='./app/etc/config.php' --exclude='./app/etc/env.php'
```
Now you can deploy to your pre-configured group

```
sh ./compile.sh
aws deploy create-deployment \
--application-name AppMagento2 \
--deployment-config-name CodeDeployDefault.OneAtATime \
--deployment-group-name MyMagentoApp \
--description "Live Deployment" \
--s3-location bucket=mage-codedeploy,bundleType=zip,eTag=<tagname>,key=live-build2.zip
```

Create this script to show where you are in the deployment

show-deployment.sh

```
aws deploy get-deployment --deployment-id $1 --query "deploymentInfo.[status, creator]" --output text
```

File 'config_files/scripts/afterInstall.bash' should run setup:upgrade --keep-generated, nginx, php-fpm restart and similar stuf 

Source (https://magento.stackexchange.com/questions/224198/magento-2-aws-automatic-codedeploy-via-github-webhook)


If you have any questions feel free send me an email  – yegorshytikov@gmail.com	

