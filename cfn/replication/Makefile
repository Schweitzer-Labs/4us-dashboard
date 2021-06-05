SHELL			:= bash
export CREPES		:= ../bin/crepes.py

ifeq ($(RUNENV), )
       export RUNENV	:= dev
endif

ifeq ($(REGION), )
       export REGION	:= us-west-1
endif


ifeq ($(RUNENV), prod)
	export WEBSITE	:= policapital
else
	export WEBSITE	:= purple
endif

export SUBDOMAIN	:= donate
export STACK		:= $(SUBDOMAIN)-$(WEBSITE)-replication

export STACKNAME	:= $(STACK)-$(RUNENV)

export DATE		:= $(shell date)
export NONCE		:= $(shell uuidgen | cut -d\- -f1)

export ENDPOINT		:= https://cloudformation-fips.$(REGION).amazonaws.com
export BUCKET		:= 4us-cfn-templates-$(REGION)

export STACK_PARAMS	:= Nonce=$(NONCE)
STACK_PARAMS		+= LambdaRunEnvironment=$(RUNENV)

export TEMPLATE		:= template.yml
export PACKAGE		:= CloudFormation-template.yml

SRCS			:= $(shell find 0* -name '*.yml' -o -name '*.txt')

.PHONY: dep build buildstacks check local import package deploy clean realclean

# Make targets
build: $(TEMPLATE)

$(TEMPLATE): $(SRCS)
	@$(CREPES) --region $(REGION) --runenv $(RUNENV) --output $(TEMPLATE) .


check: $(TEMPLATE)
	@echo "Validating template"
	@aws cloudformation validate-template --template-body file://$^


clean:
	@rm -f $(TEMPLATE) $(PACKAGE)

realclean: clean

package: build check
	@aws cloudformation package \
		--endpoint-url $(ENDPOINT) \
		--template-file $(TEMPLATE) \
		--region $(REGION) \
		--s3-bucket $(BUCKET) \
		--s3-prefix $(STACKNAME) \
		--output-template-file $(PACKAGE)

deploy: package
	@aws cloudformation deploy \
		--endpoint-url $(ENDPOINT) \
		--region $(REGION) \
		--template-file $(PACKAGE) \
		--stack-name $(STACKNAME) \
		--s3-bucket $(BUCKET) \
		--s3-prefix $(STACKNAME) \
		--capabilities \
		       CAPABILITY_NAMED_IAM \
		       CAPABILITY_AUTO_EXPAND \
		--parameter-overrides \
			$(STACK_PARAMS)
