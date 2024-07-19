FROM debian:bookworm-slim

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        jq \
        squashfs-tools; \
    install -m 0755 -d /etc/apt/keyrings; \
    curl \
        -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* 


ARG ENROOT_VERSION=3.5.0 
ENV ENROOT_BIN_DIR=/opt/enroot
RUN set -eux; \
    git clone \
        --depth 1 \
        --branch v${ENROOT_VERSION} \
        https://github.com/NVIDIA/enroot.git \
        ${ENROOT_BIN_DIR}; \
    sed -e "s|@sysconfdir|${ENROOT_BIN_DIR}/etc|" \
        -e "s|@libdir@|${ENROOT_BIN_DIR}/src|" \
        -e "s|@version@|${ENROOT_VERSION}|" \
        ${ENROOT_BIN_DIR}/enroot.in \
        > ${ENROOT_BIN_DIR}/enroot; \
    mkdir -p "${ENROOT_BIN_DIR}/etc"

WORKDIR /workspace
