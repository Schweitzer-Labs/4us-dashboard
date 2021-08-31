SRCS 		:= $(shell find 0* -name '*.yml' -o -name '*.txt')

TEMPLATE 	:= $(BUILD_DIR)/$(STACK)-crepes.yml
PACKAGE 	:= $(BUILD_DIR)/$(STACK)-CloudFormation.yml
IMPORTS		:= $(BUILD_DIR)/$(STACK)-imports.yml
IMPORT_TEMPLATE	:= $(BUILD_DIR)/$(STACK)-import-crepes.yml

IMPORTED_RESOURCES := ImportedResources.yml

ENDPOINT 	:= https://cloudformation-fips.$(REGION).amazonaws.com

STACK_IMPORT_PARAMS	+= ParameterKey=RunEnvironment,ParameterValue=$(RUNENV)
STACK_IMPORT_PARAMS	+= ParameterKey=Domain,ParameterValue=$(DOMAIN)
STACK_IMPORT_PARAMS	+= ParameterKey=SubDomain,ParameterValue=$(SUBDOMAIN)
STACK_IMPORT_PARAMS	+= ParameterKey=TLD,ParameterValue=$(TLD)

STACK_PARAMS += RunEnvironment=$(RUNENV)
STACK_PARAMS += Domain=$(DOMAIN)
STACK_PARAMS += SubDomain=$(SUBDOMAIN)
STACK_PARAMS += TLD=$(TLD)

CREPES_PARAMS	:= --region $(REGION)
CREPES_PARAMS	+= --subdomain $(SUBDOMAIN) --domain $(DOMAIN) --tld $(TLD) --runenv $(RUNENV) --product $(PRODUCT)

ASSETS_BUCKET	:= s3-$(WEB_BUCKET)
TEMPLATE_BUCKET	:= s3-$(CFN_BUCKET)

.PHONY: build buildimports import check deploy

preimport: $(ASSETS_BUCKET) $(TEMPLATE_BUCKET)
	@echo created $(WEB_BUCKET)

s3-%:
	@echo Checking if s3:/$* exists
	@echo Please ignore any "404 HeadBucket operation Not Found" errors
	@aws s3api head-bucket --region $(REGION) --bucket $* \
		|| (aws s3 mb --region $(REGION) s3://$* && :)

build: $(TEMPLATE)

check: $(TEMPLATE)
	@echo "Validating template"
	@aws cloudformation validate-template --template-body file://$^

$(TEMPLATE): $(SRCS)
	@echo "Stacking $(STACK) template into: $@"
	@$(PREBUILD)
	@$(CREPES) . \
		$(CREPES_PARAMS) \
		--output $@
	@$(POSTBUILD)

buildimports: $(IMPORTS) preimport


$(IMPORTS): $(IMPORTED_RESOURCES) $(SRCS)
	@echo "Importing resources from $(REGION) into $(STACK) via $@"
	@$(CREPES) . \
		$(CREPES_PARAMS) \
		--import $@ \
		--output $(IMPORT_TEMPLATE)

import: $(IMPORTS) buildimports
	@echo "Creating import changeset for CloudFormation template"
	@aws cloudformation create-change-set \
		--region $(REGION) \
		--endpoint-url $(ENDPOINT) \
		--stack-name $(STACK) \
		--change-set-name ImportChangeSet \
		--change-set-type IMPORT \
		--resources-to-import file://$(IMPORTS) \
		--template-body file://$(IMPORT_TEMPLATE) \
		--capabilities \
			CAPABILITY_NAMED_IAM \
		--parameters \
			$(STACK_IMPORT_PARAMS)
	@aws cloudformation describe-change-set \
		--region=$(REGION) \
		--endpoint-url $(ENDPOINT) \
		--change-set-name ImportChangeSet \
		--stack-name=$(STACK)
	@echo "Waiting for the changeset to finish creating"
	@aws cloudformation wait change-set-create-complete \
		--region=$(REGION) \
		--endpoint-url $(ENDPOINT) \
		--change-set-name ImportChangeSet \
		--stack-name=$(STACK)
	@echo "Executing the changeset"
	@aws cloudformation execute-change-set \
		--region=$(REGION) \
		--endpoint-url $(ENDPOINT) \
		--stack-name=$(STACK) \
		--change-set-name ImportChangeSet
	@aws cloudformation wait stack-import-complete \
		--region=$(REGION) \
		--endpoint-url $(ENDPOINT) \
		--stack-name=$(STACK)

package: $(PACKAGE)

$(PACKAGE): $(TEMPLATE)
	@echo "Creating $(STACK) package"
	@aws cloudformation package \
		--region $(REGION) \
		--endpoint-url $(ENDPOINT) \
		--s3-bucket $(CFN_BUCKET) \
		--s3-prefix $(STACK) \
		--template-file $^ \
		--output-template-file $@

deploy: package
	@echo "Actual command to deploy the packaged template:"
	aws cloudformation deploy \
		--endpoint-url $(ENDPOINT) \
		--s3-bucket $(CFN_BUCKET) \
		--s3-prefix $(STACK) \
		--region $(REGION) \
		--template-file $(PACKAGE) \
		--stack-name $(STACK) \
		--capabilities \
			CAPABILITY_NAMED_IAM \
			CAPABILITY_AUTO_EXPAND \
		--parameter-overrides \
			$(STACK_PARAMS)
