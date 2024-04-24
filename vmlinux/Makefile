MACHINE ?= $(shell uname -m)
KERNEL_BRANCH ?= 5.10
MAKEFILE_DIR := $(realpath $(shell dirname $(firstword $(MAKEFILE_LIST))))

# normalize machine to docker platform
ifeq ($(MACHINE),x86_64)
	PLATFORM := linux/amd64
else
	PLATFORM := linux/arm64
endif

IMAGE_TAG ?= linux.git:$(MACHINE)-$(KERNEL_BRANCH)
CONFIG_FILE ?= $(KERNEL_BRANCH)/microvm-kernel-$(MACHINE)-$(KERNEL_BRANCH).config

linux.git:
	docker build .. \
		--platform $(PLATFORM) \
		--build-arg KERNEL_BRANCH=$(KERNEL_BRANCH) \
		--tag $(IMAGE_TAG) \
		--target linux.git

# vmlinux is a build target that is not interactive, so we can run it directly
vmlinux:
	docker build .. \
		--platform $(PLATFORM) \
		--build-arg KERNEL_BRANCH=$(KERNEL_BRANCH) \
		--mount type=bind,src=$(MAKEFILE_DIR)/out,dst=/out \
		--target vmlinux-out

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
