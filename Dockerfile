FROM debian:bookworm-slim

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl; \
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
ARG DOWNLOAD_URL=https://github.com/nvidia/enroot/releases/download
RUN set -eux; \
    arch=$(dpkg --print-architecture); \
    curl -fSsL -O ${DOWNLOAD_URL}/v${ENROOT_VERSION}/enroot_${ENROOT_VERSION}-1_${arch}.deb; \
    curl -fSsL -O ${DOWNLOAD_URL}/v${ENROOT_VERSION}/enroot+caps_${ENROOT_VERSION}-1_${arch}.deb; \
    apt-get update; \
    apt-get install -y --no-install-recommends ./*.deb; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf ./*.deb

WORKDIR /workspace
ENTRYPOINT ["enroot", "import"]

