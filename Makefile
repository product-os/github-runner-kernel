SHELL := /bin/bash
ARCH ?= $(shell uname -m)
KERNEL_BRANCH ?= 6.1
# renovate: datasource=github-tags depName=gregkh/linux
KERNEL_COMMIT ?= 1ca1436ccc68275d0b43b6a730b3940fcc46b7c2
KERNEL_VERSION ?= 6.1.193
MAKEFILE_DIR := $(realpath $(shell dirname $(firstword $(MAKEFILE_LIST))))

# normalize machine to docker platform
ifeq ($(ARCH),x86_64)
	PLATFORM := linux/amd64
	MACHINE ?= x86_64
else
	PLATFORM := linux/arm64
	MACHINE ?= aarch64
endif

IMAGE_TAG ?= linux.git:$(MACHINE)-$(KERNEL_BRANCH)
CONFIG_FILE ?= config/$(KERNEL_BRANCH)/microvm-kernel-$(MACHINE)-$(KERNEL_BRANCH).config
BUILD_ARGS := \
	--build-arg KERNEL_BRANCH=$(KERNEL_BRANCH) \
	--build-arg KERNEL_COMMIT=$(KERNEL_COMMIT) \
	--build-arg KERNEL_VERSION=$(KERNEL_VERSION)

linux.git:
	docker build . \
		--platform $(PLATFORM) \
		$(BUILD_ARGS) \
		--target linux.git \
		--output type=image,name=$(IMAGE_TAG)

# vmlinux is a build target that is not interactive, so we can run it directly
vmlinux:
	docker build . \
		--platform $(PLATFORM) \
		$(BUILD_ARGS) \
		--target vmlinux-out \
		--output type=local,dest=vmlinux

# vmconfig targets are interactive, so we need to run them in a container
vmconfig: linux.git
	-docker rm -f linux.git
	docker run -it --name linux.git --platform $(PLATFORM) $(IMAGE_TAG) make $(TARGET)
	docker cp linux.git:/src/.config $(CONFIG_FILE)

menuconfig:
	make vmconfig TARGET=$@

olddefconfig:
	make vmconfig TARGET=$@

clean:
	-rm -rf out
	-docker rm -f linux.git
	-docker rm -f $(IMAGE_TAG)

.PHONY: linux.git vmlinux vmconfig menuconfig olddefconfig clean
