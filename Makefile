SHELL			:= bash
export CREPES		:= $(PWD)/cfn/bin/crepes.py
export SUBDOMAIN	:= committee

ifeq ($(RUNENV), )
       export RUNENV	:= qa
endif

ifeq ($(PRODUCT), )
	export PRODUCT	:= p2
endif

# Deduce the Domain related parameters based on the RUNENV and PRODUCT params
ifeq ($(RUNENV), qa)
        export REGION   := us-west-2
	ifeq ($(PRODUCT), 4us)
		export DOMAIN   := build4
		export TLD      := us
	else # PRODUCT = p2
		export DOMAIN   := purplepay
		export TLD      := us
	endif
else ifeq ($(RUNENV), prod)
        export REGION   := us-east-1
	ifeq ($(PRODUCT), 4us)
		export DOMAIN   := 4us
		export TLD      := net
	else
		export DOMAIN   := policapital
		export TLD      := net
	endif
else ifeq ($(RUNENV), demo)
        export REGION   := us-west-1
	export DOMAIN   := 4usdemo
	export TLD      := com
	export PRODUCT	:= 4us
else # demo
        export REGION   := us-east-2
        export DOMAIN   := 4us
        export TLD      := com
endif


export STACK		:= $(RUNENV)-$(PRODUCT)-$(SUBDOMAIN)

export DATE		:= $(shell date)
export NONCE		:= $(shell uuidgen | cut -d\- -f1)

export ENDPOINT		:= https://cloudformation-fips.$(REGION).amazonaws.com

export STACK_PARAMS	:= Nonce=$(NONCE)

export BUILD_DIR	:= $(PWD)/.build

export TEMPLATE		:= $(BUILD_DIR)/template.yml
export PACKAGE		:= $(BUILD_DIR)/CloudFormation-template.yml


CFN_SRC_DIR		:= $(PWD)/cfn/template
SRCS			:= $(shell find $(CFN_SRC_DIR)/0* -name '*.yml' -o -name '*.txt')

export CFN_BUCKET	:= $(PRODUCT)-cfn-templates-$(REGION)
export WEB_BUCKET	:= $(SUBDOMAIN)-$(RUNENV).$(DOMAIN).$(TLD)-$(REGION)

export CREPES_PARAMS	:= --region $(REGION)
export CREPES_PARAMS	+= --subdomain $(SUBDOMAIN) --domain $(DOMAIN) --tld $(TLD) --runenv $(RUNENV) --product $(PRODUCT)

.PHONY: all dep build build-web check import package deploy deploy-web clean realclean

# Make targets
all: build

dep:
	@pip3 install jinja2 cfn_flip boto3

build: $(BUILD_DIR)
	@$(MAKE) -C $(CFN_SRC_DIR) build

$(BUILD_DIR):
	@mkdir -p $@

check: build
	@$(MAKE) -C $(CFN_SRC_DIR) check


build-web: build
	@npm install
	@elm-app build

deploy-web: build-web
	aws s3 sync build/ s3://$(WEB_BUCKET)/

clean:
	@rm -f $(BUILD_DIR)/*.yml

realclean: clean
	@rm -rf $(BUILD_DIR)

package: build
	@$(MAKE) -C $(CFN_SRC_DIR) package

deploy: package
	@$(MAKE) -C $(CFN_SRC_DIR) deploy

buildimports: $(BUILD_DIR)
	@$(MAKE) -C $(CFN_SRC_DIR) buildimports

import: $(BUILD_DIR)
	@$(MAKE) -C $(CFN_SRC_DIR) import

replication:
	@$(MAKE) -C cfn/replication deploy
