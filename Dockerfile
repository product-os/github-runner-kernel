FROM debian:bookworm-slim@sha256:e67eeead736ff7bbe258ef088bff683635c561b1fcfefad0806c1df4ab49ce0e AS linux.git

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
    vim-tiny \
    zstd \
    && rm -rf /var/lib/apt/lists/*

ARG KERNEL_BRANCH=6.1
# renovate: datasource=github-tags depName=gregkh/linux
ARG KERNEL_COMMIT=1ca1436ccc68275d0b43b6a730b3940fcc46b7c2
ARG KERNEL_VERSION=6.1.193

# Fail unless the tag resolves to the pinned commit.
RUN git clone --depth 1 -c advice.detachedHead=false \
    --branch "v${KERNEL_VERSION}" https://github.com/gregkh/linux.git . \
    && actual="$(git rev-parse HEAD)" \
    && if [ "${actual}" != "${KERNEL_COMMIT}" ]; then \
        echo "v${KERNEL_VERSION} is ${actual}, expected ${KERNEL_COMMIT}" >&2; \
        exit 1; \
    fi

COPY patches/${KERNEL_BRANCH}/*.patch ./

RUN git apply -v ./*.patch

COPY config/${KERNEL_BRANCH}/*.config ./

RUN cp "microvm-kernel-$(uname -m)-${KERNEL_BRANCH}.config" .config

###############################################

FROM linux.git AS vmlinux-arm64
RUN make Image -j"$(nproc)"
# hadolint ignore=DL3059
RUN zstd --compress --no-progress --force --rm -9 arch/arm64/boot/Image -o vmlinux.bin.zst

FROM linux.git AS vmlinux-amd64
RUN make vmlinux -j"$(nproc)"
# hadolint ignore=DL3059
RUN zstd --compress --no-progress --force --rm -9 vmlinux -o vmlinux.bin.zst

# hadolint ignore=DL3006
FROM vmlinux-${TARGETARCH} AS vmlinux

###############################################

FROM scratch AS vmlinux-out

COPY --from=vmlinux /src/vmlinux.bin.zst /vmlinux.bin.zst
