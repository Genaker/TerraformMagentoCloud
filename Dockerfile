# Minimal image with Terraform and Terragrunt
FROM hashicorp/terraform:1.8

SHELL ["/bin/sh", "-c"]

# Optional: set SKIP_TLS_VERIFY=true at build time to relax TLS checks
ARG SKIP_TLS_VERIFY=false
ENV GIT_SSL_NO_VERIFY=${SKIP_TLS_VERIFY}

# Install deps and Terragrunt
RUN apk add --no-cache curl htop nano unzip ca-certificates bash go git build-base && \
    TG_VERSION="v0.92.1" && \
    curl -kfsSL -o /usr/local/bin/terragrunt \
      https://github.com/gruntwork-io/terragrunt/releases/download/${TG_VERSION}/terragrunt_linux_amd64 && \
    chmod +x /usr/local/bin/terragrunt && \
    if [ "${SKIP_TLS_VERIFY}" = "true" ]; then \
      git config --system http.sslVerify false; \
      go env -w GOINSECURE="*" GOPRIVATE="*" GONOSUMDB="*"; \
    fi && \
    terragrunt --version && terraform -version && go version

WORKDIR /work

# Default to an interactive shell; override with `docker run ... terragrunt <args>`
ENTRYPOINT ["/bin/sh"]

