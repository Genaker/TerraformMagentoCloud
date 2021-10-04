# Deployment Information

**Install Ansible**
```
pip install ansible 
ansible-galaxy collection install amazon.aws
```
# Tag Instances

Auto Scaling Group tags will be propagated to the newly created instances:
![image](https://user-images.githubusercontent.com/9213670/135914856-eebea483-ae74-4c1d-a750-994900957193.png)

See: https://docs.aws.amazon.com/autoscaling/ec2/userguide/autoscaling-tagging.html

A tag is a custom attribute label that you assign or that AWS assigns to an AWS resource. Each tag has two parts:

A tag key (for example, costcenter, environment, or project).

An optional field known as a tag value (for example, 111122223333 or production).

Tags help you do the following:

 - Track your AWS costs. You activate these tags on the AWS Billing and Cost Management dashboard. AWS uses the tags to categorize your costs and deliver a monthly cost allocation report to you. For more information, see Using cost allocation tags in the AWS Billing and Cost Management User Guide.

 - Control access to Auto Scaling groups based on tags. You can use conditions in your IAM policies to control access to Auto Scaling groups based on the tags on that group. For more information, see Tagging for security.

 - Identify and organize your AWS resources. Many AWS services support tagging, so you can assign the same tag to resources from different services to indicate that the resources are related.

You can tag new or existing Auto Scaling groups. You can also propagate tags from an Auto Scaling group to the Amazon EC2 instances it launches.

Auto Scaling Terraform Tags example: 
```
  tags = [{
          key = "Deployment_Group"
          value = "web"
          propagate_at_launch = true
         }]
```

**Create file aws_ec2:**
Add filter with the instances tags you want to deploy (Deployment_Group = web):
```
plugin: aws_ec2
regions:
  - us-east-2
Filters:
# all instances with their `Name` tag set to `web-instance`
  tag:Deployment_Group: web
hostnames:
  - ip-address
``` 
About filters you can read here: 
https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html#options

**List Inventory**
```
ansible-inventory -i aws_ec2.yml --list
```

**Run Command Ping**
```
ansible all -i aws_ec2.yml -m ping
```

**RUN Deployment Playbook** 
```
ansible-playbook -i aws_ec2.yml deployment.yml
```
