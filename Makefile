HAS_AWS := $(shell command -v aws 2> /dev/null)
AWS_NOT_INSTALLED_MSG := printf "\n\033[1;31m🔴 AWS CLI is not installed. 🔴\033[0m\n\n\033[1mPlease install it from:\033[0m https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html\n\n"
IS_AUTHENTICATED_AWS := $(shell aws sts get-caller-identity 2> /dev/null)
AWS_NOT_AUTHENTICATED_MSG := printf "\n\033[1;31m🔴 You are not authenticated with AWS. 🔴\033[0m\n\n\033[1mPlease run:\033[0m make aws-login\n\n"

## Silence the default make output
MAKEFLAGS += -s

all: help

##@ Terramate
deploy:  ## Deploy the infrastructure
	@terramate generate
	@terramate script run --changed deploy
list:  ## List the stacks
	@terramate list
order:  ## Show the running order execution
	@terramate list --run-order
generate:  ## Generate the Terraform code
	@terramate generate
format:  ## Format the Terramate code
	@terramate fmt
destroy:  ## Destroy the infrastructure
	@terramate run --reverse -- terraform destroy
generate-ids:  ## Generate the IDs of the stacks
	@terramate create --ensure-stack-ids

##@ Utilities
help:  ## Display this help
	@awk 'BEGIN {FS = " "; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} \
	/^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } \
	/^[a-zA-Z\-_0-9\\:]+:.*##/ { gsub("\\\\:", ":", $$1); gsub(":$$", "", $$1); printf "  \033[36m%-18s\033[0m %s\n", $$1, substr($$0, index($$0,"##")+2) }' $(MAKEFILE_LIST)