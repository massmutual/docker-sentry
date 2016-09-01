NAME = datascience-sentry
VERSION ?= latest
GIT_COMMIT_TAG ?= none
IMAGE_NAME = "m38io/$(NAME)"
INSTANCE = default
CONTAINER_NAME = "$(NAME).$(INSTANCE)"
BUILD_IMAGE_NAME = "$(IMAGE_NAME):build"
TEST_CONTAINER_NAME = "$(NAME).$(INSTANCE).test"
DOCKER_BUILD_CONTEXT = .
DOCKERFILE = $(DOCKER_BUILD_CONTEXT)/Dockerfile
APP_PATH = /usr/src/sentry

ERROR_COLOR = \033[1;31m
WARN_COLOR = \033[1;33m
NO_COLOR = \033[0m

.PHONY: build push stop rm verify-auth

default: build

guard-%:	# Add an implicit guard for parameter input validation
	@if [ "${${*}}" = "" ]; then \
		printf \
			"$(ERROR_COLOR)Error: Variable [$*] not set.$(NO_COLOR)\n"; \
		exit 1; \
	fi

help:		## Prints the names and descriptions of available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

verify-auth: # Verifies caller has authenticated with DockerHub (target not shown on help menu to avoid confusion)
	@if [ ! -f ~/.docker/config.json ]; then \
		printf \
	"$(WARN_COLOR)Docker config file was not found, if you encounter issues \
	verify you are logged into Docker Hub using the 'docker login' command.$(NO_COLOR)\n"; \
	fi

login: guard-DOCKER_USER guard-DOCKER_PASSWORD guard-DOCKER_EMAIL	## Authenticate with remote Docker repository
	@docker login \
		--username $(DOCKER_USER) \
		--password $(DOCKER_PASSWORD) \
		--email $(DOCKER_EMAIL)

##
### Docker targets
##
build: verify-auth	## Build the docker image

# The following code will build the image once but then tag the image multiple times. This avoids needing to rebuild
# the binary when no changes have occurred.
#
# The multi-line loop is needed below so "make" will execute everything in a single sub-shell. If these commands are
# separated into separate commands BASH variable assignment will be lost.

	@docker build -t $(BUILD_IMAGE_NAME) -f $(DOCKERFILE) $(DOCKER_BUILD_CONTEXT); \
	for v in $(VERSION); \
	do \
		docker tag -f $(BUILD_IMAGE_NAME) "$(IMAGE_NAME):$$v"; \
	done;

pull: verify-auth	## Pull Docker image from remote repository
	@for v in $(VERSION); do docker pull $(IMAGE_NAME):$$v; done

push: verify-auth	## Push the docker image to its remote repository (always performed by automated build)
	@for v in $(VERSION); do docker push $(IMAGE_NAME):$$v; done

stop:	## Stop docker container
	@docker stop $(CONTAINER_NAME)

rm:		## Remove docker container
	@docker rm $(CONTAINER_NAME)

##
### Environment targets
##

env-start: build	## Launch docker environment using configuration specified within docker-compose.yml
	@docker-compose up

env-start-d: build	## Launch docker environment in background
	@docker-compose up -d

env-stop:	## Stop docker container
	@docker-compose stop
