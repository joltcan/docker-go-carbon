# Makefile for go-carbon docker builds.
# By: Fredrik Lundhag <f@mekk.com>
CONTAINER  := go-carbon
IMAGE_NAME := $(CONTAINER)
BUILD_NAME := "$(IMAGE_NAME)-build"
DATA_DIR   := $(shell pwd)
DOCKER     := docker
HUB_USER   := $(USER)
VERSION	   := 0.14.0
TAG		   := $(VERSION)

build:
	if $(DOCKER) ps -a |grep -q $(BUILD_NAME); \
		then echo $(BUILD_NAME) exist, skipping; \
		else $(DOCKER) run --name $(BUILD_NAME) golang sh -c "go get github.com/lomik/go-carbon ; cd /go/src/github.com/lomik/go-carbon/ ; git checkout $(VERSION) ; CGO_ENABLED=0 GOOS=linux go get -ldflags \"-s\" -a -installsuffix cgo github.com/lomik/go-carbon"; \
    fi

	$(DOCKER) cp $(BUILD_NAME):/go/bin/go-carbon .
	$(DOCKER) cp $(BUILD_NAME):/go/src/github.com/lomik/go-carbon/deploy/go-carbon.conf .
	$(DOCKER) cp $(BUILD_NAME):/go/src/github.com/lomik/go-carbon/deploy/storage-aggregation.conf .
	$(DOCKER) cp $(BUILD_NAME):/go/src/github.com/lomik/go-carbon/deploy/storage-schemas.conf .
	$(DOCKER) \
		build \
		--rm --tag=$(IMAGE_NAME) .
	-rm go-carbon >/dev/null

run:
	$(DOCKER) \
		run \
		--detach \
		--rm \
		--user $(id -u):$(id -g) \
		--publish=2003:2003 \
		--publish=2003:2003/udp \
		--publish=2004:2004 \
		--publish=7002:7002 \
		--publish=7003:7003 \
		--publish=7007:7007 \
		--publish=8000:8000 \
		--publish=8008:8080 \
		--volume=${DATA_DIR}:/var/lib/graphite \
		--volume=${DATA_DIR}:/etc/go-carbon \
		--volume=${DATA_DIR}/logs:/var/log/go-carbon \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME)

stop:
	$(DOCKER) \
		kill ${CONTAINER}

history:
	$(DOCKER) \
		history ${IMAGE_NAME}

clean:
	-$(DOCKER) rmi --force $(IMAGE_NAME)
	-$(DOCKER) rmi --force $(BUILD_NAME)
	-$(DOCKER) rm --force $(BUILD_NAME)
	-$(DOCKER) rmi --force $(registry)/$(BUILD_NAME)
	-$(DOCKER) rmi --force $(registry)/$(IMAGE_NAME)

push: 
	$(DOCKER) tag $(CONTAINER) $(HUB_USER)/$(CONTAINER):$(TAG) && \
	$(DOCKER) tag ${CONTAINER} ${HUB_USER}/${CONTAINER}:latest && \
	$(DOCKER) push $(HUB_USER)/$(CONTAINER):$(TAG) && \
	$(DOCKER) push ${HUB_USER}/${CONTAINER}:latest 

commit:
	$(DOCKER) commit -m "Built version ${TAG}" -a "${USER}" ${CONTAINER} ${HUB_USER}/${CONTAINER}:${TAG}

