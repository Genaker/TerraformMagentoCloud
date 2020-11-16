# Infrastructure as code for eCommerce Cloud Architecture on AWS (Multi Cloud AWS,GCP,Azure)

This repository contains Magento 2 Cloud Terraform infrastructure as code for AWS Public Cloud.

This infrastructure is the result of years of experience scaling Magento 1 and 2 in the cloud. It comes with the best cloud development practices baked in to save your time and money.

Leveraging your own AWS Account dramatically reduces your monthly spend vs. paying an expensive managed hosting provider (PaaS, SaaS).

This script is not limited to Magento deployments and can be used with any eCommerce/Web platform, eg. WordPress, WooCommerce, Drupal, Shopware 6, Shopify APP (Custum Private APP cloud), VueStorefront, Silyus, Oddo, ORO etc. It includes Magento in the name because it was designed for Magento at first. There are however projects using it to run Enterprise Java applications with auto scaling.

# Why Auoto Scaling 

Increasing the number of PHP-FPM processes beyond the number of physical processor cores does not improve the performance, rather is likely to degrade it, and can consume resources needlessly. Basic rule for the web is:

CPU(physical) = (Concurrent HTTP REquest * http_req_duration)

Be careful Intel CPUs are virtual and actual number of CPUs factor = 2; Graviton AWS ARM64 CPUS have factor 1 and are better for concurrent request processing. 
Intel CPUs have some advantages of 20-30% in some cases, however for magento (long heavy queries) physical cores are better. With higher trafic you need more CPUs.
It is rule for uncached pages.  

With Varnish/FPC it is the same. However Varnish has response time ~ 1ms and a single instance CPU can return 1000 caches pages per sec. To avoid unpredictable results with the cache invalidation, misses, uncached checkouts, cart, AJAXs, API the BEST practices is to measure performance without FPC. FPC is a bonus.


## AWS Magento 2 Cloud Features:
* True Horizontal Auto Scaling 
* Affordable (starting from ~300$ for us-west-2 region)
* MySQL RDS scalable Managed by Amazon, multi az failover, vertical scaling without downtime
* Compatible with RDS Aurora Cluster and Aurora Serverless
* EFS - Fully managed elastic NFS for media and configuration storage
* CloudFront CDN for static and media served from different origins S3 or Magento(EFS) as second origin 
* Automatically back up your code and databases (point-in-time snapshot) for easy restoration
* 99.9% Uptime, availability across multiple zones
* High security (Security groups, private infrastructure)
* Elastic(Static) IP and used for internet access for all EC2 instances through NAT (Network Address Translation).
* Bastion host to provide Secure Shell (SSH) access to the Magento web servers. 
* Appropriate security groups for each instance or function to restrict access to only necessary protocols and ports.
* Private Public Subnets - NAT gateway, Bastion server
* All servers and Database are hosted in private Network securely
* System and Software Update Patches
* DDoS Protection with AWS Shield
* PCI compliant infrastructure
* Redis cluster
* Amazon Elasticsearch Service - Elasticsearch at scale with zero down time with built-in Kibana
* Different Application Scaling Groups (ASG)
* Application Load Balancer(ALB) with SSL/TSL termination, SSL certificates management
* ALB Path-Based Routing, Host-Based Routing, Lambda functions as targets, HTTP header/method-based routing, Query string parameter-based routing 		
* Scaled Varnish ASG
* Dedicated Admin/Cron ASG
* You can easily add new autoscaling groups for your needs (Per WebSite/for Checkout requests/for API), just copy paste code 
* Possibility to run the same infrastructure on Production/Staging/Dev environment, different projects
* Automatic CI/CD (CodePipeline/CodeDeploy) deployments possible
* AWS CodeDeploy In-place deployment, Blue/green deployment from Git or S3, Redeploy or Roll Back
* Deploying from a Development Account to a Production Account
* Amazon Simple Email Service (Amazon SES) - cloud-based email sending service. Price $0.10 for 1K emails 
* Amazon CloudWatch - load all the metrics (CPU, RAM, Network) in your account for search, graphing, and alarms. Metric data is kept for 15 months.
* CloudWatch alarms that watche a single CloudWatch metric or the result of a math expression based on CloudWatch metrics and send SMS(Text) Notifications or Emails
* Simple and Step Scaling Policies - choose scaling metrics that trigger horizontal scaling
* Manual Scaling for Magento Auto Scaling Group (ASG)
* AWS Command Line Interface (CLI) - tool to manage your AWS services. You can control multiple AWS services from the command line and automate them through scripts.
* DynamoDb for logs, indexes, analytics
* Lambda functions as targets for a load balancer
* Elastic Container Registry (ECR) - fully-managed Docker container registry that makes it easy to store, manage, and deploy Docker container images!
* You can use Amazon Elastic Container Service (ECS) instead of ASG with Service Auto Scaling to adjust running containers desired count automatically.
* Awesome AWS documentation is Open Source and on GitHub

![Magento 2 AWS Infrastructure Cloud ](https://github.com/Genaker/TerraformMagentoCloud/blob/master/Magento2Cloud.png)

[Cloud Flat View](https://github.com/Genaker/TerraformMagentoCloud/blob/master/Magento2Cloud-Flat.png)

# Our Infrastructure

Infrastructure consists of multiple layers (autoscaling, alb, rds, security-group, vpc) where each layer is configured using one of the [Terraform AWS modules](https://github.com/terraform-aws-modules/) with arguments specified in `terraform.tfvars` in layers directory.

Terraform uses this during the module installation step of `terraform init` to download the source code to a directory on local disk so that it can be used by other Terraform commands.

The [https://registry.terraform.io/](public Terraform registry) provides infrastructure modules for many infrastructure resources.

[Terragrunt](https://github.com/gruntwork-io/terragrunt) is used to work with Terraform configurations which allows you to orchestrate dependent layers, update arguments dynamically and keep configurations. Define Terraform code once, no matter how many environments you have ([DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself)).


## Pre-requirements

- [Terraform 0.12 or newer](https://www.terraform.io/)
- [Terragrunt 0.19 or newer](https://github.com/gruntwork-io/terragrunt)
- [tfvars-annotations](https://github.com/antonbabenko/tfvars-annotations) - Update values in terraform.tfvars using annotations
- Optional: [pre-commit hooks](http://pre-commit.com) to keep Terraform formatting and documentation up-to-date

# Install HomeBrew on Linux

Paste at a terminal prompt:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
The installation script installs Homebrew to /home/linuxbrew/.linuxbrew using sudo if possible and, if not, in your home directory at ~/.linuxbrew. Homebrew does not use sudo after installation. Using /home/linuxbrew/.linuxbrew allows the use of more binary packages (bottles) than installing in your personal home directory.

The followig instructions will add Homebrew to your PATH and to your bash shell profile script (either ~/.profile on Debian/Ubuntu or ~/.bash_profile on CentOS/Fedora/RedHat).
```
test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile
echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile
```
You’re done! Try installing a package:
```
brew install hello
```
If you’re using an older distribution of Linux, installing your first package will also install a recent version of glibc and gcc. Use `brew doctor` to troubleshoot common issues.

If you are using Mac you can install all dependencies using Homebrew:

    $ brew install terraform terragrunt pre-commit
    
## Manual install:

You can install Terragrunt manually by going to the [Releases page](https://github.com/gruntwork-io/terragrunt/releases), downloading the binary for your OS, renaming it to terragrunt and adding it to your PATH.

# Install Terragrunt and Terraform Ubuntu Manually
```
sudo -s; ## run as a super user
    export TERRAFORM_VERSION=0.12.24 \
    && export TERRAGRUNT_VERSION=0.23.2 \
    && mkdir -p /ci/terraform_${TERRAFORM_VERSION} \
    && wget -nv -O /ci/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip -o /ci/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
    && mkdir -p /ci/terragrunt-${TERRAGRUNT_VERSION}/ \
    && wget -nv -O /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && sudo chmod a+x /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt \
    && cp /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt /bin \
    && chmod a+x /bin/terragrunt \
    && rm -rf /ci \
    && exit
```
Test The Terragrunt/Terraform installation(Optional):
```
terragrunt -v;
terraform -v
```

## Instructions for use

Step 0. Terraform uses the SSH protocol to clone the modules. Configured SSH keys will be used automatically. Add your SSH key to github account. (https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account)

Git+SSH is used because it works for both public and private repositories.

Step 1. Set credentials. By default, access credentials to AWS account should be set using environment variables:
```
     export AWS_DEFAULT_REGION=us-west-1 ## change it to your preferable AWS region
     export AWS_ACCESS_KEY_ID=...
     export AWS_SECRET_ACCESS_KEY=...
```
Alternatively, you can edit `common/main_providers.tf` and use another authentication mechanism as described in the [AWS provider documentation](https://www.terraform.io/docs/providers/aws/index.html#authentication).

Step 2. Once all arguments are set, run this command to create infrastructure in all layers in a single region:

    $ cd production
    $ terragrunt apply-all

Alternatively, you can create infrastructure in a single layer (eg, `autoscaling_3`):

    $ cd production/autoscaling_3
    $ terragrunt apply

See [official Terragrunt documentation](https://github.com/gruntwork-io/terragrunt/blob/master/README.md) for all available commands and features.


# Demo video showing how it works (click on image)

<a href="https://www.youtube.com/watch?v=kmnlrXSTQlM">
<img alt="Magento AWS Cloud" src="https://github.com/Genaker/TerraformMagentoCloud/blob/master/Magento2Cloud-Flat.png" width="50%" height="50%">
</a>

or click url: (https://www.youtube.com/watch?v=kmnlrXSTQlM)

Architecting your Magento platform to grow with your business can sometimes be a challenge. This video walks through the steps needed to take an out-of-the-box, single-node Magento implementation and turn it into a highly available, elastic, and robust deployment. This includes an end-to-end caching strategy that provides an efficient front-end cache (including populated shopping carts) using Varnish on Amazon EC2 as well as offloading the Magento caches to separate infrastructure such as [https://aws.amazon.com/elasticache/](Amazon ElastiCache). We also look at strategies to manage the Magento Media library outside of the application instances, including [https://aws.amazon.com/efs/](EFS shared storage solutions).


# Debug logging

If you set the TERRAGRUNT_DEBUG environment variable to “true”, the stack trace for any error will be printed to stdout when you run the app.

Additionally, newer features introduced in v0.19.0 (such as locals and dependency blocks) can output more verbose logging if you set the TG_LOG environment variable to debug.

Turn on debug when you need do troubleshooting.
```
# or if you run with terragrunt
TF_LOG=DEBUG terragrunt <command>
```

# Clearing the Terragrunt cache

Terragrunt creates a .terragrunt-cache folder in the current working directory as its scratch directory. It downloads your remote Terraform configurations into this folder, runs your Terraform commands in this folder, and any modules and providers those commands download also get stored in this folder. You can safely delete this folder any time and Terragrunt will recreate it as necessary.

If you need to clean up a lot of these folders (e.g., after terragrunt apply-all), you can use the following commands on Mac and Linux:

Recursively find all the .terragrunt-cache folders that are children of the current folder:
```
find . -type d -name ".terragrunt-cache"
```
If you are ABSOLUTELY SURE you want to delete all the folders that come up in the previous command, you can recursively delete all of them as follows:
```
find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
```
Also consider setting the TERRAGRUNT_DOWNLOAD environment variable if you wish to place the cache directories somewhere else.

# Destroy Terragrunt Magento Infrastructure 
```
terraform destroy-all 
```
Infrastructure managed by Terraform will be destroyed. This will ask for confirmation before destroying.

This command accepts all the arguments and flags that the apply command accepts, with the exception of a plan file argument.

If -auto-approve is set, then the destroy confirmation will not be shown.

The -target flag, instead of affecting "dependencies" will instead also destroy any resources that depend on the target(s) specified. For more information, see the [Targeting section of the terraform plan documentation](https://www.terraform.io/docs/commands/plan.html#resource-targeting).

The behavior of any terraform destroy command can be previewed at any time with an equivalent `terraform plan -destroy` command.


# Production staging environments 

You can copy/paste folders to create new environments. Consider the following file structure, which defines three magento environments (prod, project-3 and stage) with the same infrastructure in each one (an app, a MySQL database, and a VPC):
```
└── magento
    ├── prod
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    ├── project-3
    │   ├── app
    │   │   └── main.tf
    │   ├── mysql
    │   │   └── main.tf
    │   └── vpc
    │       └── main.tf
    └── stage
        ├── app
        │   └── main.tf
        ├── mysql
        │   └── main.tf
        └── vpc
            └── main.tf
```    
The contents of each environment will be more or less identical, except perhaps for a few settings (eg. the prod environment may use bigger or more servers). As the size of the infrastructure grows, having to maintain all of this duplicated code between environments becomes more error prone. You can reduce the amount of copying and pasting using Terraform modules, but even the code to instantiate a module and set up input variables, output variables, providers and remote state can still create a lot of maintenance overhead.

Terragrunt allows you to keep your Magento backend configuration DRY (“Don’t Repeat Yourself”) by defining it once in a root location and inheriting that configuration in all child modules. Let’s say your Terraform code has the following folder layout:
```
stage
├── frontend-app
│   └── main.tf
└── mysql
    └── main.tf
``` 
To use Terragrunt, add a single terragrunt.hcl file to the root of your repo, in the stage folder, and one terragrunt.hcl file in each module folder:
```
stage
├── terragrunt.hcl
├── frontend-app
│   ├── main.tf
│   └── terragrunt.hcl
└── mysql
    ├── main.tf
    └── terragrunt.hcl
```
Now you can define your backend configuration just once in the root terragrunt.hcl file!


# Multi cloud deployments 

Terraform provides Magento 2 Open Source Cloud infrastructure as a code approach to the provision and manage any cloud (AWS, GoogleCloud, Azure, Alibaba, or other types of services such as Kubernetes).

Terraform can manage popular service providers, such as AWS, GCP, Micosoft Azure, Alibaba Cloud, and VMware, as well as custom in-house and on-premises solutions.

## Enterprise Support/Installation/Development Package available.
Several Magento development Agencies select this custom cloud solution for their clients and they are willing to provide services/support for businesses based on this Open Source project.
Nowerdays this project has 10+ partners. 
If you are willing to be listed as cloud service provider feel free message me.


More information: yegorshytikov@gmail.com

I also have Ansible Magento Cloud provisioning implementation:
https://github.com/Genaker/AWS_Magento2_Ansible

And also Magento Cloud provisioning Using AWS CDK. Comming soon ...


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
# eCommerce Cloud Price Visualisation 

![Magento 2 AWS Cloud Cost](https://github.com/Genaker/TerraformMagentoCloud/blob/master/small-big.png)

# Why not Magento Cloud?
```
+-----------------------------------------+-------------------------------------------+
|              Magento Cloud              |               This Solution               |
+-----------------------------------------+-------------------------------------------+
| Manual scaling, requires prior notice,  | Unlimited Resource, scaling by rule,      |
| vertical scaling,                       | no performance degradation                |
| performance degradation during scaling  |                                           |
+-----------------------------------------+-------------------------------------------+
| Fastly CDN only                         | Completely CDN agnostic,                  |
|                                         |  works with Cloudflare, CloudFront        |
+-----------------------------------------+-------------------------------------------+
| Works only with Enterprise version M2   | Works with any version of Magento 1/2     |
+-----------------------------------------+-------------------------------------------+
| Expansive $2000-$10000 month +          | Paying only for AWS resources you used,   |
| Enterprise license                      | starting from 300$ months                 |
+-----------------------------------------+-------------------------------------------+
| Not Customizable                        | Fully Customizeble                        |
+-----------------------------------------+-------------------------------------------+
| Host only single Magento 2 CE           | Can host multiple project, web sites,     |
| installation                            | tech stacks, PHP, Node.JS, Python, Java;  |
|                                         | Magento 1/2, WordPres, Drupal, Joomla,    |
|                                         | Presta Shop, Open Cart, Laravel, Django   |
+-----------------------------------------+-------------------------------------------+
```

# Basic Deployment With CodeDeploy Example 

## Code and application deployment is beyond the scope of this repo. This repo for infrastructure provisioning only!!!

AWS CodeDeploy is a managed deployment technology. It provides great features like rolling deployments, automatic rollback, and load balancer integration. It is technology agnostic and Amazon uses it to deploy everything. 

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

Script to 'compile' magento on Deploy server - You pull and compile code to deploy server or build Docker container end after just push code to production using Code Deploy - fastest way 

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

File 'config_files/scripts/afterInstall.bash' should run setup:upgrade --keep-generated, nginx, php-fpm restart and similar stuff

Source (https://magento.stackexchange.com/questions/224198/magento-2-aws-automatic-codedeploy-via-github-webhook)

##How to Deploy With Docker 

Just run command in your codeDeploy script 

```
docker pull [OPTIONS] MAGENTO_IMAGE_NAME[:TAG|@DIGEST]

```

# Automate the installation of software using Golden AMI

A “golden AMI” or “gold image” is an Magento AMI you standardize through configuration, consistent security patching, and hardening. It also contains agents you approve for logging, security, performance monitoring, etc. Many enterprise customers have a mature AMI pipeline setup to create a golden AMI of base operating systems for the organization. For a sample golden AMI pipeline, see [The Golden AMI Pipeline] (https://aws.amazon.com/blogs/awsmarketplace/announcing-the-golden-ami-pipeline/).

You can launch an instance from an existing AMI, customize the instance, setup Software (Magento, ODDO, Wordpress, Shopware etc.) and then save this updated configuration as a custom AMI. Instances launched from this new custom AMI include the customizations that you made when you created the AMI.

# Magento 2 Installation Automatio (Centos 8.2, AWS linux with ARM support) GitHub reposetory:

[Magento installation Script] (https://github.com/Genaker/Magento-AWS-Linux-2-Instalation).

# Building an Golden AMI with Packer

Packer is an open-source tool by Hashicorp that automates the creation of machine images for different platforms. Developers specify the machine configuration using a JSON file called template, and then run Packer to build the image.


One key feature of Packer is its capability to create images targeted to different platforms, all from the same specification. This is a nice feature that allows you to create machine images of different types without repetitive coding.

You can get Packer and its documentation at the [Packer official site](https://www.packer.io/).  


# Use DynamoDb with Magento 2

Magento out of the box has a PHP Library to work with Dynamo DB. 

```
use Aws\DynamoDb\Exception\DynamoDbException;
use Aws\DynamoDb\Marshaler;

$sdk = new Aws\Sdk([
    'endpoint'   => 'http://localhost:8000',
    'region'   => 'us-west-2',
    'version'  => 'latest'
]);

$dynamodb = $sdk->createDynamoDb();
$marshaler = new Marshaler();

$tableName = 'Movies';

$year = 2015;
$title = 'The Big New Movie';

$item = $marshaler->marshalJson('
    {
        "year": ' . $year . ',
        "title": "' . $title . '",
        "info": {
            "plot": "Nothing happens at all.",
            "rating": 0
        }
    }
');

$params = [
    'TableName' => 'Movies',
    'Item' => $item
];

try {
    $result = $dynamodb->putItem($params);
    echo "Added item: $year - $title\n";

} catch (DynamoDbException $e) {
    echo "Unable to add item:\n";
    echo $e->getMessage() . "\n";
}

?>
```

You can record logs to a DynamoDB table with the AWS SDK and Monolog using /Monolog/Handler/DynamoDbHandler.php

When Time to Live (TTL) is enabled on a table in Amazon DynamoDB, a background job checks the TTL attribute of items to determine whether they are expired.

Also you can use the Amazon Web Services CloudWatch Logs Handler for Monolog library to integrate Magento 2 Monolog with CloudWatch Logs (https://github.com/maxbanton/cwh).

```
php composer.phar require maxbanton/cwh:^1.0
```


If you have any questions feel free to send me an email – yegorshytikov@gmail.com

Terraform AWS moules maintained by [Anton Babenko](https://github.com/antonbabenko)

All content, including [Terraform AWS modules](https://github.com/terraform-aws-modules/) used in these configurations, is released under the MIT License. 
 


