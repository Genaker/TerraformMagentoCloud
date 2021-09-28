# Deployment Information

**Install Ansible**
```
pip install ansible 
ansible-galaxy collection install amazon.aws
```

**Create file aws_ec2:**
```
plugin: aws_ec2
regions:
  - us-east-2
Filters:
# all instances with their `Name` tag set to `web-instance`
  tag:Name: web-instance
hostnames:
  - ip-address
``` 

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
