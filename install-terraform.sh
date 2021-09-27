## run as a super user
export TERRAFORM_VERSION=1.0.7 \
&& export TERRAGRUNT_VERSION=0.32.4 \
&& mkdir -p /ci/terraform_${TERRAFORM_VERSION} \
&& wget -nv -O /ci/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip /ci/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /ci/terraform_${TERRAFORM_VERSION}/ \
&& sudo chmod a+x /ci/terraform_${TERRAFORM_VERSION}/terraform \
&& cp /ci/terraform_${TERRAFORM_VERSION}/terraform /usr/local/bin/ \
&& chmod a+x /bin/terraform \
&& mkdir -p /ci/terragrunt_${TERRAGRUNT_VERSION}/ \
&& wget -nv -O /ci/terragrunt_${TERRAGRUNT_VERSION}/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
&& sudo chmod a+x /ci/terragrunt_${TERRAGRUNT_VERSION}/terragrunt \
&& cp /ci/terragrunt_${TERRAGRUNT_VERSION}/terragrunt /usr/local/bin/ \
&& chmod a+x /bin/terragrunt \
&& rm -rf /ci 
