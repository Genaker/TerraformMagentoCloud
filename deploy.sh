#!/bin/bash
## Execution log of this file located in instance
## On Amazon Linux, RHEL, and Ubuntu Server instances, deployment logs are stored in the following location:
##  /var/log/aws/codedeploy-agent/codedeploy-agent.log
## You can also type the following command to open an AWS CodeDeploy scripts log file:
## less /opt/codedeploy-agent/deployment-root/{deployment-group-ID}/{deployment-ID}/logs/scripts.log

## ENV variables
## 1.  LIFECYCLE_EVENT : This variable contains the name of the lifecycle event associated with the script.
## 2.  DEPLOYMENT_ID :  This variables contains the deployment ID of the current deployment.
## 3.  APPLICATION_NAME :  This variable contains the name of the application being deployed. This is the name the user sets in the console or AWS CLI.
## 4.  DEPLOYMENT_GROUP_NAME :  This variable contains the name of the deployment group. A deployment group is a set of instances associated with an application that you target for a deployment.
## 5.  DEPLOYMENT_GROUP_ID : This variable contains the ID of the deployment group in AWS CodeDeploy that corresponds to the current deployment

## Bash more strict
# Enable exit on non 0
set -e
# If something fails with exit!=0 the script stops

EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"

cd /var/www/html/magento

mkdir -p deploy_code

GITV=$(<./deployment/git_version.txt)

echo "GIT version : $GITV"

if [[ "$EC2_REGION" == "us-west-1" ]]
    then
    echo "Upload from S3 California"
    aws s3 cp "s3://ideployment/code-$GITV.tar.gz" .
fi

if [[ "$EC2_REGION" == "us-west-2" ]]
    then
    echo "Upload from S3 Oregon"
    aws s3 cp "s3://ideployment-oregon/code-$GITV.tar.gz" .
fi

echo "UnTar Started"

tar --overwrite -xvzf "code-$GITV.tar.gz"

echo "Untar Finished"

rm "code-$GITV.tar.gz"

echo "Tar deleted"

echo "Restart PHP-FPM - update PHP opcached code"
service php7.1-fpm restart


echo "Show Magento Mode deploy:mode:show"
php bin/magento deploy:mode:show

DEPLOY_DIRECTORY="/opt/codedeploy-agent/deployment-root/$DEPLOYMENT_GROUP_ID/$DEPLOYMENT_ID/deployment-archive/deployment/"

if [[ "$GIT_PULL_ONLY" == "true" ]]
    then
    echo "GIT PULL ONLY"
    exit 0
fi

DATE=`date '+%Y-%m-%d+%H-%M-%S'`

AWS_INSTANCE_ID=`ec2metadata --instance-id`
EC2_NAME=$(aws ec2 describe-tags --region "$EC2_REGION" \
--filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=Name" --output text | cut -f5)

echo "Instance Name $EC2_NAME"

## only one instance should have tag setup=upgrade
EC2_SETUP_UPGRADE_MACHINE=$(aws ec2 describe-tags --region "$EC2_REGION" \
--filters "Name=resource-id,Values=$AWS_INSTANCE_ID" "Name=key,Values=setup" --output text | cut -f5)

echo "Instance setup tag  - $EC2_SETUP_UPGRADE_MACHINE"


echo "Deployment ID: $DEPLOYMENT_ID"
echo "\n"

#rm -rf var/cache/* var/page_cache/* var/composer_home/* var/tmp/*
#php composer  update --no-interaction --no-progress --optimize-autoloader

## Prevent errors when privious deployment fails
#rm -rf generated/*
#bin/magento setup:di:compile

[[ $? -ne 0 ]] && echo "SOME ERROR"

if [[ "$SETUP_UPDATE" == "true" ]] && [[ "$EC2_SETUP_UPGRADE_MACHINE"  ==  "upgrade" ]]
    then
        ##ToDo:Database backup before update;
        echo "Run SETUP:UPGRADE only on admin machine with tag setup = upgrade"
        echo "Setup:Upgrade"
        echo "true" > ./deployment/update.lock
        bin/magento setup:upgrade --keep-generated
        #bin/magento setup:di:compile
        rm -rf ./deployment/update.lock
fi

[[ $? -ne  0 ]] && echo "SOME ERROR"


if [[ "$DI_COMPILE" == "true" ]]
    then
    echo "DI:Upgrade"
    rm -rf generated/*
    bin/magento setup:di:compile
fi

## Generate new static version

#bin/magento setup:static-content:deploy en_US es_ES
## Run this command on machine with new static files and copy new static files to EFS for deployment to EC2
# sudo fpsync -n 10 -v -o '-aru ' /var/www/html/magento/pub/static /tmp/magento/tmp/static
mkdir -p  /tmp/magento/tmp/static
#rm -rf /tmp/magento/tmp/static/*

if [[ "$SYNC_STATIC" == "true" ]]
    then
    fpsync -n 10 -v -o '-ar ' /tmp/magento/tmp/static /var/www/html/magento/pub/static
fi

## Replace Magento Core Files
rsync -av deployment/code/* vendor/

echo "clear cache"
php bin/magento c:c

echo "Make code files and directories read-only \n"
#echo "Setting directory base permissions to 0750"
#find . -type d -exec chmod 0750 {} \;
#echo "Setting file base permissions to 0640"
#find . -type f -exec chmod 0640 {} \;
chmod o-rwx app/etc/env.php
chown www-data:www-data app/etc/env.php
chmod u+x bin/magento
echo "permission for folders"
chmod -R 777 generated/*  > /dev/null 2>&1 &

# Waiting N seconds because permission running asyc
sleep 10

chmod -R 777 var/* > /dev/null 2>&1 &


echo "SYNC PHP.INI"
cat ./deployment/etc/php/7.1/fpm/php.ini > /etc/php/7.1/fpm/php.ini

echo "Disable maintenance mode \n"
php bin/magento maintenance:disable
service php7.1-fpm restart
service nginx restart

if [[ "$SYNC_CRON" == "true" ]]
    then
    # Disable exit on non 0
    set +e
    crontab -l > var/crontab.$DATE || true
    ## Add crontab not from root su - <username> -c "<commands>"
    [[ "$EC2_NAME" == "AdminWebNode" ]] && cat deployment/crontab_admin.txt | crontab -
    [[ "$EC2_NAME" == "WebNode" ]] && cat deployment/crontab_web.txt | crontab -
    ## php bin/magento cron:install
    ##  $content = (string)$this->shell->execute('crontab -l');
    ## $this->shell->execute('echo "' . $content . '" | crontab -');
    ##crontab -l | grep "Ran jobs by schedule || sudo echo "* * * * * www-data /usr/bin/php /var/www/html/magento/bin/magento cron:run | grep -v Ran jobs by schedule >> /var/www/html/magento/var/log/magento.cron.log" >> /tmp/magento && sudo cp /tmp/magento /etc/cron.d/
fi
## Install EFS mounts fstub file

if [[ "$SYNC_FSTAB" == "true" ]]
    then
    ## check file cmp --silent  deployment/etc/fstab /etc/fstab

    mkdir -p /tmp/magento/tmp

    ##Password file for S3 mount
    cat deployment/passwd-s3fs > /home/ubuntu/.passwd-s3fs
    chmod 600 /home/ubuntu/.passwd-s3fs

    cat /etc/fstab > var/fstab.$DATE
    cat deployment/etc/fstab > /etc/fstab

    #mount  fstab file

    mount -all
fi

echo "Deployment Finished!!!"
