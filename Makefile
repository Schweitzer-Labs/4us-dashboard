export SHELL		:= env PATH=$(PATH) bash
export SUBDOMAIN	:= dashboard
export PRODUCT		:= 4us

ifeq ($(RUNENV), )
       export RUNENV	:= qa
endif


ifeq ($(RUNENV), qa)
	export DOMAIN   := build4
	export TLD      := us
else ifeq ($(RUNENV), prod)
	export DOMAIN   := 4us
	export TLD      := net
else ifeq ($(RUNENV), demo)
	export DOMAIN   := 4usdemo
	export TLD      := com
else #extra
        export DOMAIN   := 4us
        export TLD      := com
endif


export BUILD_DIR	:= $(PWD)/build

COGNITO_DOMAIN	:= https://platform-user-$(PRODUCT)-$(RUNENV).auth.$(REGION).amazoncognito.com
COGNITO_REDIRECT_URI	:= https://$(SUBDOMAIN).$(DOMAIN).$(TLD)
DONOR_URL		:= https://donate.$(DOMAIN).$(TLD)
API_ENDPOINT		:= https://committee-api.$(DOMAIN).$(TLD)/api/committee/graphql

COGNITO_USER_POOL = $(eval COGNITO_USER_POOL := $$(shell aws cognito-idp list-user-pools --region $(REGION) --max-results 10 --query 'UserPools[?starts_with(Name, `PlatformUserPool`)].Id' --output text))$(COGNITO_USER_POOL)

COGNITO_CLIENT_ID = $(eval COGNITO_CLIENT_ID := $$(shell aws cognito-idp list-user-pool-clients --region $(REGION) --user-pool-id $(COGNITO_USER_POOL) --query 'UserPoolClients[*].ClientId' --output text))$(COGNITO_CLIENT_ID)

.PHONY: all dep build clean realclean

# Make targets
all: build

clean:
	@rm -f $(BUILD_DIR)/*

realclean: clean
	@rm -rf $(BUILD_DIR)
	@rm -rf node_modules

dep:
	@npm install


$(BUILD_DIR):
	@mkdir -p $@

build: dep $(BUILD_DIR)
	echo $(COGNITO_USER_POOL) $(COGNITO_CLIENT_ID)
	npm \
		--domain=$(COGNITO_DOMAIN) \
		--redirect=$(COGNITO_REDIRECT_URI) \
		--apiendpoint=$(API_ENDPOINT) \
		--donorurl=$(DONOR_URL) \
		--clientid=$(COGNITO_CLIENT_ID) \
		run build
