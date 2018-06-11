ENVS := aws-dev aws-test aws-prod
env :=  aws-dev
PREFIX := $(shell echo $(env) |shasum -a 256|cut -c 1-12)
KEY := $(shell pwd | xargs basename)
TF_ENV_VARS := 
AWS_ENV :=
S3_PATH :=

.PHONY: help
help:
	@echo "make (plan|apply|autoapply) [env=]"
	@echo "		e.g. make plan ENV=(`echo $(ENVS) | tr ' ' \|`) [default: $(env)]"
	@echo " "
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

tf_init: 
ifeq ($(filter $(env),$(ENVS)),)
	$(error $(env) is not supported)
endif
ifdef CI
	$(eval S3_PATH = services/$(CI_PROJECT_NAME))
else 
	$(if $(findstring deploy,$(KEY)), $(eval KEY := services/$(shell cd .. && pwd | xargs basename)))
	$(eval AWS_ENV = $(env))
	$(eval S3_PATH = $(KEY))
endif
	@echo "# PREFIX: $(PREFIX)"
	@echo "# AWS_ENV: $(AWS_ENV)"
	@if [ -e .terraform/terraform.tfstate ]; then rm .terraform/terraform.tfstate; fi;
	$(eval TF_ENV_VARS := $(TF_ENV_VARS) AWS_PROFILE=$(AWS_ENV) )
	@echo "# TF_ENV_VARS: $(TF_ENV_VARS)"
	$(TF_ENV_VARS) terraform init -backend-config="bucket=akoehler-$(PREFIX)-state" -backend-config="dynamodb_table=akoehler-$(PREFIX)-state-lock" -backend-config="key=$(S3_PATH)/terraform.tfstate"

tf_vars:
	$(eval TF_OPTIONS :=  $(TF_OPTIONS) -var aws-account=$(AWS_ENV))
	$(eval TF_OPTIONS :=  $(TF_OPTIONS) -var tf-statefile-prefix=$(PREFIX))
	$(if $(wildcard .env.$(env)), $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var-file ".env.$(env)"))
	$(if $(wildcard .env), $(eval TF_OPTIONS :=  $(TF_OPTIONS) -var-file ".env"))
	@echo "# TF_OPTIONS= "$(TF_OPTIONS)

.PHONY: plan 
plan: tf_init tf_vars
	$(TF_ENV_VARS) terraform plan $(TF_OPTIONS)

.PHONY: apply
apply: tf_init tf_vars
	$(TF_ENV_VARS) terraform apply $(TF_OPTIONS)

.PHONY: destroy 
destroy: tf_init tf_vars
	$(TF_ENV_VARS) terraform destroy $(TF_OPTIONS)

.PHONY: autoapply
autoapply: tf_init tf_vars
	$(TF_ENV_VARS) terraform apply -auto-approve $(TF_OPTIONS)
