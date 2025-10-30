he docker file andt# Local testing with Terragrunt + Terraform + LocalStack

This guide shows how to run plans/applies locally against LocalStack using a Docker image that contains Terraform and Terragrunt. It does not change behavior for real AWS runs.

## Prerequisites
- Docker Desktop running
- LocalStack running on your host
  - Default port: `4566`
  - If LocalStack uses a different port (e.g., `4567`), set `LOCALSTACK_ENDPOINT` accordingly

## Build the tools image (once)
```powershell
cd C:\Users\<YOUR_USER>\TerraformMagentoCloud
docker build -t tg-tf:local .
```

## Environment variables (PowerShell)
```powershell
$env:USE_LOCALSTACK = "true"
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "ap-southeast-1"
$env:TERRAGRUNT_DISABLE_INIT = "true"
# Change this if LocalStack uses a non-default port
$env:LOCALSTACK_ENDPOINT = "http://host.docker.internal:4566"
```

## Plan/apply a single module (example: production/aws-data)
Plan:
```powershell
docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production/aws-data `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TERRAGRUNT_DISABLE_INIT=$env:TERRAGRUNT_DISABLE_INIT `
  tg-tf:local -lc "set -e; mkdir -p /tmp/tf-cache; export TF_PLUGIN_CACHE_DIR=/tmp/tf-cache; export TF_CLI_ARGS_init='-backend=false -reconfigure'; rm -rf .terragrunt-cache; terragrunt plan -input=false -no-color"
```

Apply:
```powershell
docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production/aws-data `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TERRAGRUNT_DISABLE_INIT=$env:TERRAGRUNT_DISABLE_INIT `
  tg-tf:local -lc "set -e; mkdir -p /tmp/tf-cache; export TF_PLUGIN_CACHE_DIR=/tmp/tf-cache; export TF_CLI_ARGS_init='-backend=false -reconfigure'; terragrunt apply -auto-approve -input=false -no-color"
```

## Run-all across production
Plan all:
```powershell
docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TERRAGRUNT_DISABLE_INIT=$env:TERRAGRUNT_DISABLE_INIT `
  tg-tf:local -lc "set -e; mkdir -p /tmp/tf-cache; export TF_PLUGIN_CACHE_DIR=/tmp/tf-cache; export TF_CLI_ARGS_init='-backend=false -reconfigure'; rm -rf .terragrunt-cache; terragrunt run-all plan -input=false -no-color"
```

Apply all:
```powershell
docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/magento-cloud-minimal/production `
  --entrypoint /bin/sh `
  -e USE_LOCALSTACK=$env:USE_LOCALSTACK `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=$env:AWS_ACCESS_KEY_ID `
  -e AWS_SECRET_ACCESS_KEY=$env:AWS_SECRET_ACCESS_KEY `
  -e AWS_DEFAULT_REGION=$env:AWS_DEFAULT_REGION `
  -e TERRAGRUNT_DISABLE_INIT=$env:TERRAGRUNT_DISABLE_INIT `
  tg-tf:local -lc "set -e; mkdir -p /tmp/tf-cache; export TF_PLUGIN_CACHE_DIR=/tmp/tf-cache; export TF_CLI_ARGS_init='-backend=false -reconfigure'; terragrunt run-all apply -auto-approve -input=false -no-color"
```

## Terratest (using the same tg-tf:local image)
The tools image includes Go, so you can run tests from it directly.

```powershell
# Point to your LocalStack port
$env:LOCALSTACK_ENDPOINT = "http://host.docker.internal:4566"  # or 4567

docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/tests `
  --entrypoint /bin/sh `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=test `
  -e AWS_SECRET_ACCESS_KEY=test `
  -e AWS_DEFAULT_REGION=ap-southeast-1 `
  tg-tf:local -lc "go test -v ./..."
```

### If your network MITM breaks TLS (skip certificate verification)
Only enable for local testing in controlled networks. These flags relax verification for Go module and git downloads.

```powershell
$env:LOCALSTACK_ENDPOINT = "http://host.docker.internal:4566"  # or 4567

docker run --rm -it `
  -v ${PWD}:/work `
  -w /work/tests `
  --entrypoint /bin/sh `
  -e LOCALSTACK_ENDPOINT=$env:LOCALSTACK_ENDPOINT `
  -e AWS_ACCESS_KEY_ID=test `
  -e AWS_SECRET_ACCESS_KEY=test `
  -e AWS_DEFAULT_REGION=ap-southeast-1 `
  -e GIT_SSL_NO_VERIFY=1 `
  -e GOINSECURE=* `
  -e GOPRIVATE=* `
  -e GONOSUMDB=* `
  tg-tf:local -lc "git config --global http.sslVerify false; go env -w GOINSECURE=\"*\" GOPRIVATE=\"*\" GONOSUMDB=\"*\"; go test -v ./..."
```

Module name: `magento-localstack-test` (see `tests/go.mod`).

## Speed up tests (short)
- Pre-bake deps into image:
```dockerfile
COPY tests/go.mod /tmp/tests/go.mod
COPY tests/go.sum /tmp/tests/go.sum
RUN cd /tmp/tests && go mod download
```

- Persistent dev container with caches:
```powershell
docker run -d --name tg-dev `
  -v ${PWD}:/work `
  -v tg-gomod:/go/pkg/mod `
  -v tg-gobuild:/root/.cache/go-build `
  -w /work/tests `
  tg-tf:local sleep infinity
docker exec tg-dev sh -lc "go test -v ./..."
```

## Troubleshooting
- Port in use (4566): point `LOCALSTACK_ENDPOINT` to the active port (e.g., `http://host.docker.internal:4567`).
- Provider install errors on Windows volumes: keep using `/tmp/tf-cache` inside the container.
- Backend initialization errors: ensure `TF_CLI_ARGS_init='-backend=false -reconfigure'` is set.
- Go module TLS errors: use the "skip certificate verification" block above or bake your corporate CA into the image.
