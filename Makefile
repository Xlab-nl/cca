.PHONY: ca build bundles help

export DEFAULT_BUNDLES = default

# CA Settings
export CA_DAYS        ?= 730
export CA_CONFIG_DIR  ?= ./config
export CA_SERIAL      ?= '01'

# Client Settings
export DAYS         ?= 365
export COUNTRY      ?= NL
export STATE        ?= Amsterdam
export LOCALITY     ?= Amsterdam
export ORGANISATION ?= None
export UNIT         ?= None
export COMMON_NAME  ?= client_certificate
export EMAIL        ?= none@none.com

default: ca

ca: build ## create ca certificates
	@./create_ca.sh ${bundle}

client: build ## create client certificates
	@./create_client.sh ${name} ${bundle}

build: bundles certs ## build initializes the build

bundles: ## create bundles dir
	@mkdir -p bundles

certs: ## create certs dir
	@mkdir -p certs

help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

