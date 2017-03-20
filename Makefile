
CONTAINER  := go-carbon
IMAGE_NAME := $(CONTAINER)
BUILD_NAME := "$(IMAGE_NAME)-build"
DATA_DIR   := $(shell pwd)
DOCKER     := docker

build:
	if $(DOCKER) ps -a |grep -q $(BUILD_NAME); \
    then echo $(BUILD_NAME) exist, skipping; \
    else $(DOCKER) run --name $(BUILD_NAME) golang sh -c "CGO_ENABLED=0 GOOS=linux go get -ldflags \"-s\" -a -installsuffix cgo github.com/lomik/go-carbon"; \
    fi
	$(DOCKER) cp $(BUILD_NAME):/go/bin/go-carbon .
	$(DOCKER) \
		build \
		--rm --tag=$(IMAGE_NAME) .
	-rm go-carbon >/dev/null

run: build 
	$(DOCKER) \
		run \
		--rm \
		--tty \
		--interactive \
		--publish=2003:2003 \
		--publish=2003:2003/udp \
		--publish=2004:2004 \
		--publish=7002:7002 \
		--publish=7007:7007 \
		--publish=8008:8008 \
		--volume=${DATA_DIR}:/srv/carbon \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME)

shell:
	$(DOCKER) \
		run \
		--rm \
		--tty \
		--interactive \
		--publish=2003:2003 \
		--publish=2003:2003/udp \
		--publish=2004:2004 \
		--publish=7002:7002 \
		--publish=7007:7007 \
		--publish=8008:8008 \
		--volume=${DATA_DIR}:/srv/carbon \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME) \
		/bin/sh

exec:
	$(DOCKER) exec \
		--rm \
		--tty \
		--interactive \
		${CONTAINER} \
		/bin/bash

stop:
	$(DOCKER) \
		kill ${CONTAINER}

history:
	$(DOCKER) \
		history ${IMAGE_NAME}

clean:
	-$(DOCKER) \
		rm ${IMAGE_NAME}
	-$(DOCKER) \
		rm $(BUILD_NAME)
push:
	$(DOCKER) tag docker-go-carbon jolt/$(IMAGE_NAME) && $(DOCKER) push jolt/$(IMAGE_NAME)