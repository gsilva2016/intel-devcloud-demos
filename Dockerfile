#
# Copyright (C) 2023-2024 Intel Corporation.
#
#
# -----------------------------------------------------------

# Add "-devel" for development image
# Remove -dpcpp for not dpcpp image
# For more info refer to: https://hub.docker.com/r/intel/dlstreamer/tags
ARG BASE_IMAGE=intel/dlstreamer:2023.0.0-ubuntu22-gpu682-dpcpp

FROM $BASE_IMAGE as release

USER root
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /

# Install dependencies for compiling OpenCV 4.7.0, GStreamer, etc..
ARG BUILD_DEPENDENCIES="cmake build-essential git-gui python3 python3-pip clang wget curl vim"
RUN apt -y update && \
    apt install -y ${BUILD_DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Install Discrete GPU drivers for Arc. Enables media FF hardware.
# Note replace arc with flex or max using DGPU_TYPE below
#ARG DGPU_TYPE="arc"
#RUN apt update -y; apt install -y wget curl vim gpg-agent; wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg; echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy $DGPU_TYPE" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list; apt update -y; DEBIAN_FRONTEND=noninteractive apt-get install -y \
#intel-opencl-icd intel-level-zero-gpu level-zero intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo libcanberra-gtk-module

# Install OneVPL CPU & Intel GPU hardware accelerated media

# Copy reference sources
#WORKDIR /app
RUN ls -l; git clone https://github.com/gsilva2016/vision-self-checkout.git
RUN cd vision-self-checkout; git checkout intel-devcloud;
#RUN cp -R vision-self-checkout/configs/gst-ovms /app/gst-ovms; \
#cp vision-self-checkout/get-media-codec.sh /app/gst-ovms; \
#cp vision-self-checkout/configs/gst-ovms/launch-pipeline.sh /app/gst-ovms; \
#cp -R vision-self-checkout/download_models/ /tmp

RUN mkdir -p /app/dlstreamer/models
COPY yolo_efficientnet.sh /app/dlstreamer
RUN cp -R vision-self-checkout/download_models/ /tmp
RUN cd /tmp/download_models/; ./modelDownload.sh --refresh; cp -R /tmp/configs/dlstreamer/models/2022/* /app/dlstreamer/models/

#RUN cd /app/gst-ovms/pipelines; chmod +x build-demos.sh; ./build-demos.sh

#USER ovms

#ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:/usr/local/lib/x86_64-linux-gnu/:/usr/local/lib:/ovms/lib:$LD_LIBRARY_PATH
WORKDIR /app/dlstreamer

ENTRYPOINT ["/bin/bash", "-c"]
