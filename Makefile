# file to store all environment variables
VARIABLES_FILE := ./.env

ifneq (,$(wildcard $(VARIABLES_FILE)))
    include $(VARIABLES_FILE)
    export ENV_FILE_PARAM = --env-file $(VARIABLES_FILE)
endif

# Colors
red := `tput setaf 1`
green := `tput setaf 2`
blue := `tput setaf 6`
purple := `tput setaf 4`
reset := `tput sgr0`

ENDPOINT="--endpoint-url=http://127.0.0.1:4566"

# default option twhen run "make" command
.DEFAULT_GOAL := help
.EXPORT_ALL_VARIABLES:

##@ Target
help:  ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


deploy-localstack: ## Deploy Localstack
	@$(MAKE) destroy-localstack
	@echo "\n\n${blue}Installing Localstack"
	@docker-compose up -d
	@bash -c "while ! curl -s localhost:4566 > /dev/null; do echo ${blue}Waiting for localstack to be up and running...; sleep 2; done; echo ${green}Localstack is UP!"


destroy-localstack: ## Destroy localstack
	@echo "\n\n${blue}Destroying Localstack${purple}"
	@docker rm -f localstack || true


s3-create-bucket: ## Create the bucket
	@echo "\n\n${blue}Creating a bucket example...${purple}"
	@aws $(ENDPOINT) s3api create-bucket --bucket mybucket --no-cli-pager


s3-remove-bucket: ## Destroy the bucket
	@echo "\n\n${blue}Deleting a bucket${purple}"
	@aws $(ENDPOINT) s3 rb s3://mybucket


s3-list-buckets: ## List all buckets
	@echo "${blue}Listing the buckets${purple}"
	@aws $(ENDPOINT) s3 ls


s3-list-bucket-content: ## List all objects of the bucket
	@echo "\n\n${blue}Listing the contents of a bucket${purple}"
	@aws $(ENDPOINT) s3 ls s3://mybucket


s3-delete-bucket-file: ## Delete the object from the bucket
	@echo "\n\n${blue}Deleting a file of a bucket${purple}"
	@aws $(ENDPOINT) s3 rm s3://mybucket/file.txt


s3-download-bucket-file: ## Gets the object from the bucket
	@echo "\n\n${blue}Downloading the file from the bucket${purple}"
	@aws $(ENDPOINT) s3 cp s3://mybucket/file.txt file.txt
	@cat file.txt


lambda-create: ## Create the lambda
	@echo "\n\n${blue}Creating a lambda function example${purple}"
	@envsubst < index.tpl > index.js
	@zip lambda.zip index.js
	@aws $(ENDPOINT) lambda create-function --function-name=example --runtime="nodejs12.x" --role=fakerole --handler=index.handler --zip-file fileb://lambda.zip --no-cli-pager


lambda-update: ## Update the lambda
	@echo "\n\n${blue}Updating lambda function${purple}"
	@envsubst < index.tpl > index.js
	@zip lambda.zip index.js
	@aws $(ENDPOINT) lambda update-function-code --function-name=example --zip-file fileb://lambda.zip --no-cli-pager


lambda-delete: ## Delete the lambda
	@echo "\n\n${blue}Deleting lambda function${purple}"
	@aws $(ENDPOINT) lambda delete-function --function-name example


lambda-list-functions: ## List all lambda functions
	@echo "\n\n${blue}Listing lambda functions${purple}"
	@aws $(ENDPOINT) lambda list-functions --no-cli-pager


lambda-invoke: ## Invoke the lambda
	@echo "\n\n${blue}Invoking example lambda function${purple}"
	@aws $(ENDPOINT) lambda invoke --function-name example out --log-type Tail --query 'LogResult' --output text |  base64 -d

clean: ## Clean unecessary files
	@echo "\n\n${blue}Cleaning unecessary files${purple}"
	@rm -rf lambda.zip out index.js file.txt || true

example-01: deploy-localstack create-resources clean ## Run the full example
create-resources: s3-create-bucket lambda-create lambda-invoke s3-list-bucket-content s3-download-bucket-file clean ## Create all the lambda and s3 resources
destroy-resources: s3-delete-bucket-file s3-remove-bucket lambda-delete clean ## Destroy all the lambda and s3 resources
destroy: destroy-localstack clean ## Destroy Localstack with everything
