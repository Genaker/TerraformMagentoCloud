sudo -s; ## run as a super user
export TERRAFORM_VERSION=1.0.7 \
&& export TERRAGRUNT_VERSION=0.31.11 \
&& mkdir -p /ci/terraform_${TERRAFORM_VERSION} \
&& wget -nv -O /ci/terraform_${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& mkdir -p /ci/terragrunt-${TERRAGRUNT_VERSION}/ \
&& wget -nv -O /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
&& sudo chmod a+x /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt \
&& cp /ci/terragrunt-${TERRAGRUNT_VERSION}/terragrunt /bin \
&& chmod a+x /bin/terragrunt \
&& rm -rf /ci \
&& exit
