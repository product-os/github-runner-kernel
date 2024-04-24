FROM debian:bullseye-slim AS linux.git

WORKDIR /src

ARG DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bc \
    binutils \
    bison \
    build-essential \
    ca-certificates \
    cpio \
    flex \
    git \
    libelf-dev \
    libncurses-dev \
    libssl-dev \
    lz4 \
    vim-tiny \
    && rm -rf /var/lib/apt/lists/*

ARG KERNEL_BRANCH=5.10

RUN git clone --depth 1 -c advice.detachedHead=false \
    --branch "v${KERNEL_BRANCH}" https://github.com/torvalds/linux.git .

COPY vmlinux/${KERNEL_BRANCH}/*.patch ./

RUN git apply -v ./*.patch

COPY vmlinux/${KERNEL_BRANCH}/*.config ./

RUN ln -sf "microvm-kernel-$(uname -m)-${KERNEL_BRANCH}.config" .config

###############################################

FROM linux.git AS vmlinux-arm64
RUN make Image && lz4 -9 ./arch/arm64/boot/Image ./vmlinux.bin.lz4

FROM linux.git AS vmlinux-amd64
RUN make vmlinux && lz4 -9 ./vmlinux ./vmlinux.bin.lz4

# hadolint ignore=DL3006
FROM vmlinux-${TARGETARCH} AS vmlinux

###############################################

FROM scratch AS vmlinux-out

COPY --from=vmlinux /src/vmlinux.bin.lz4 /vmlinux.bin.lz4
