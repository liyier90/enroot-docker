ARG BASE_IMAGE=ubuntu:22.04

FROM --platform=linux/amd64 ${BASE_IMAGE} as dev-base

ARG DEBIAN_FRONTEND=noninteractive
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git; \
    rm -rf /var/lib/apt/lists/* 

RUN set -eux; \
    curl -fsSLv -o ~/conda.sh -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh"; \
    chmod +x ~/conda.sh; \
    ~/conda.sh -b -p /opt/conda; \
    rm ~/conda.sh

ARG PYTHON_VERSION=3.11
RUN set -eux; \
    /opt/conda/bin/conda install -y \
        python=${PYTHON_VERSION} \
        c-compiler \
        cxx-compiler \
        cmake \
        ninja \
        sysroot_linux-64; \
    /opt/conda/bin/conda clean -ya

ARG TORCH_VERSION=2.4.0
ARG CUDA_VERSION=12.4
RUN set -eux; \
    /opt/conda/bin/conda install -y \
        -c pytorch \
        -c "nvidia/label/cuda-${CUDA_VERSION}.0" \
        -c "nvidia/label/cuda-${CUDA_VERSION}.1" \
        pytorch==${TORCH_VERSION} \
        torchvision \
        torchaudio \
        pytorch-cuda=${CUDA_VERSION} \
        cuda-toolkit=${CUDA_VERSION}; \
    /opt/conda/bin/conda clean -ya

ENV PATH=/opt/conda/bin:${PATH}

ARG NCCL_VERSION=2.21.5
RUN set -eux; \
    mkdir /tmp/mybuild; \
    cd /tmp/mybuild; \
    curl -fsSLv -O https://developer.download.nvidia.com/compute/redist/nccl/v${NCCL_VERSION}/nccl_${NCCL_VERSION}-1+cuda${CUDA_VERSION}_$(uname -m).txz; \
    tar -xf nccl*; \
    mv nccl*/ /opt/nccl; \
    rm -rf /tmp/mybuild

ARG MAX_JOBS=4
ARG APEX_VERSION=24.04.01
RUN set -eux; \
   mkdir /tmp/mybuild; \
   cd /tmp/mybuild; \
   git clone -b ${APEX_VERSION} https://github.com/NVIDIA/apex.git; \
   cd apex; \
   pip install -v --disable-pip-version-check --no-cache-dir --no-build-isolation --config-settings "--build-option=--cpp_ext" --config-settings "--build-option=--cuda_ext" ./; \
   rm -rf /tmp/mybuild

ARG FLASH_ATTN_VERSION=2.4.2
RUN set -eux; \
    pip install -v --no-build-isolation flash-attn==${FLASH_ATTN_VERSION}

ARG CUDNN_VERSION=9.2.1.18_cuda12
RUN set -eux; \
    mkdir /tmp/mybuild; \
    cd /tmp/mybuild; \
    arch=$(uname -m); \
    curl -fsSLv -O https://developer.download.nvidia.com/compute/cudnn/redist/cudnn/linux-${arch}/cudnn-linux-${arch}-${CUDNN_VERSION}-archive.tar.xz; \
    tar -xf cudnn*; \
    mv cudnn*/ /opt/cudnn; \
    rm -rf /tmp/mybuild

ENV CUDNN_PATH=/opt/cudnn
ENV CUDNN_LIBRARY=/opt/cudnn
ENV CUDNN_LIB_DIR=/opt/cudnn/lib
ENV CUDNN_INCLUDE_DIR=/opt/cudnn/include

ARG CMAKE_BUILD_PARALLEL_LEVEL=1
ARG MAX_JOBS=1
ARG TRANSFORMER_ENGINE_VERSION=v1.8
RUN set -eux; \
    mkdir /tmp/mybuild; \
    cd /tmp/mybuild; \
    git clone -b ${TRANSFORMER_ENGINE_VERSION} --recurse-submodules https://github.com/NVIDIA/TransformerEngine.git; \
    cd TransformerEngine; \
    NVTE_FRAMEWORK=pytorch pip install -v ./; \
    rm -rf /tmp/mybuild
    

