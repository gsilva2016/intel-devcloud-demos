#
# Copyright (C) 2023-2024 Intel Corporation.
#
#
# -----------------------------------------------------------

# https://hub.docker.com/r/openvino/model_server
ARG BASE_IMAGE=openvino/model_server:2023.1-gpu
FROM $BASE_IMAGE as release

USER root
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]
WORKDIR /

# Install dependencies for compiling OpenCV 4.7.0, GStreamer, etc..
ARG BUILD_DEPENDENCIES="cmake build-essential git-gui python3 python3-pip flex bison clang libgtk2.0-dev libhdf5-serial-dev libvtk9-dev libtbb2 libxml2 curl libpugixml1v5"
RUN apt -y update && \
    apt install -y ${BUILD_DEPENDENCIES} && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Install Discrete GPU drivers for Arc. Enables media FF hardware.
# Note replace arc with flex or max using DGPU_TYPE below
ARG DGPU_TYPE="arc"
RUN apt update -y; apt install -y wget curl vim gpg-agent; wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg; echo "deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy $DGPU_TYPE" | tee /etc/apt/sources.list.d/intel-gpu-jammy.list; apt update -y; DEBIAN_FRONTEND=noninteractive apt-get install -y \
intel-opencl-icd intel-level-zero-gpu level-zero intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2 libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all vainfo libcanberra-gtk-module

# Install GStreamer build dependencies
RUN apt -y update; DEBIAN_FRONTEND=noninteractive apt install -y libva-dev autoconf libtool libpciaccess-dev libssl-dev pkg-config libdrm-dev libgbm-dev libcogl-pango-dev libudev-dev lld libx11-xcb-dev libpciaccess-dev nasm yasm libx11-dev libxcb-present-dev libxcb-dri3-dev xorg xorg-dev libgl1-mesa-glx libgl1-mesa-dev meson libgudev-1.0-dev

# Install OneVPL CPU & Intel GPU hardware accelerated media
RUN apt -y update; DEBIAN_FRONTEND=noninteractive apt install -y wget unzip
RUN wget https://github.com/oneapi-src/oneVPL/archive/refs/tags/v2023.3.1.zip
RUN unzip v2023.3.1.zip
RUN cd oneVPL*; export VPL_INSTALL_DIR=/opt/intel/onevpl; mkdir _build; mkdir $VPL_INSTALL_DIR; cd _build; cmake .. -DCMAKE_INSTALL_PREFIX=$VPL_INSTALL_DIR; cmake --build . --config Release; cmake --build . --config Release --target install
RUN wget https://github.com/oneapi-src/oneVPL-intel-gpu/archive/refs/tags/intel-onevpl-23.2.4.zip
RUN unzip intel-onevpl-23.2.4.zip
RUN cd oneVPL-intel-gpu*; mkdir build; cd build; cmake ..; make -j`nproc`; make install

# Build GStreamer
# Latest 1.22 is in a different repo: https://gitlab.freedesktop.org/gstreamer/gstreamer.git
#RUN git clone https://github.com/GStreamer/gst-build.git;
#RUN git clone https://gitlab.freedesktop.org/gstreamer/gstreamer.git
#RUN cd gst-build; git checkout 1.22;
#RUN export PKG_CONFIG_PATH=/opt/intel/mediasdk/lib/pkgconfig/:/opt/intel/onevpl/lib/pkgconfig; cd gst-build; meson builddir --buildtype=release -Dvaapi=enabled -Dbad=enabled -Dgst-plugins-bad:msdk=enabled -Dgst-plugins-bad:mfx_api=oneVPL -Dgst-plugins-good:soup=disabled -Dgst-plugin-good:ffmpeg=disabled -Dintrospection=disabled -Dgst-plugin-good:sqlite3=disabled -Dpygobject:gobject-introspection=disabled -Dgst-plugins-bad:openjpeg=disabled -Dgst-plugins-bad:tests=disabled -Dgst-plugins-bad:examples=disabled -Dtests=disabled -Dexamples=disabled -Dgst-examples=disabled -Dgst-plugins-ugly:x264=disabled -Dsharp=disabled -Domx=disabled -Dlibnice=disabled -Dpython=disabled -Dges=disabled -Drs=disabled -Dtools=disabled -Drtsp_server=disabled -Doss_fuzz=disabled; 
#RUN cd gst-build; ninja -j `nprocs` -C builddir;
#RUN cd gst-build; cd builddir; ninja install
RUN apt-get -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio

# Build OpenCV with GStreamer HW Accel
#RUN opencv_branch=${opencv_branch:-4.7.0}; \
#work_dir=${work_dir:-/opt}; \
#current_working_dir=$(pwd); \
#cd $work_dir; \
#git clone https://github.com/opencv/opencv.git --depth 1 -b $opencv_branch $work_dir/opencv_repo; \
#git clone https://github.com/opencv/opencv_contrib.git; \
#cd $work_dir/opencv_contrib; git checkout 4.7.0; \
#cd $work_dir/opencv_repo; \
#mkdir -p $work_dir/opencv_repo/build; \
#cd $work_dir/opencv_repo/build; \
#cmake \
#-D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
#-D VIDEOIO_PLUGIN_LIST=gstreamer \
#-D WITH_GSTREAMER=ON \
#-D WITH_FFMPEG=OFF \
#-D CMAKE_BUILD_TYPE=Release \
#-D CMAKE_INSTALL_PREFIX=/usr/lib \
#-D OPENCV_LIB_INSTALL_PATH=x86_64-linux-gnu \
#-D WITH_OPENJPEG=OFF \
#-D WITH_JASPER=OFF \
#-D WITH_OPENEXR=OFF \
#-D WITH_TIFF=OFF \
#-D WITH_GTK=ON $work_dir/opencv_repo && \
#make "-j`nprocs`" && \
#make install

# COPY OVMS runtime
WORKDIR /
RUN wget -O ovms.tar.gz https://github.com/openvinotoolkit/model_server/releases/download/v2023.1/ovms_ubuntu22.tar.gz
#COPY ovms.tar.gz /
RUN tar -xf ovms.tar.gz
##RUN find / -name *ovms*.so
#RUN rm /ovms/lib/*opencv*;

# Copy C-API sources
RUN DEBIAN_FRONTEND=noninteractive apt install -y jq libopencv-dev python3-opencv gstreamer1.0-plugins-base-apps -y && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:/usr/local/lib/x86_64-linux-gnu/:/usr/local/lib:/ovms/lib:$LD_LIBRARY_PATH

WORKDIR /app
RUN ls -l; git clone https://github.com/gsilva2016/vision-self-checkout.git
RUN cd vision-self-checkout; git checkout intel-devcloud;
RUN cp -R vision-self-checkout/configs/gst-ovms /app/gst-ovms; \
cp vision-self-checkout/get-media-codec.sh /app/gst-ovms; \
cp vision-self-checkout/configs/gst-ovms/launch-pipeline.sh /app/gst-ovms; \
cp -R vision-self-checkout/download_models/ /tmp
RUN cd /tmp/download_models/; ./downloadGSTOVMSModels.sh; cp -R /tmp/configs/gst-ovms/models/* /app/gst-ovms/models/
RUN cd /app/gst-ovms/pipelines; chmod +x build-demos.sh; ./build-demos.sh
#COPY configs/gst-ovms /home/intel/gst-ovms
#COPY get-media-codec.sh /home/intel/gst-ovms/
#COPY configs/gst-ovms/launch-pipeline.sh /home/intel/gst-ovms/
#RUN cd /home/intel/gst-ovms/pipelines; chmod +x build-demos.sh; ./build-demos.sh

USER ovms

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/:/usr/local/lib/x86_64-linux-gnu/:/usr/local/lib:/ovms/lib:$LD_LIBRARY_PATH

# Enable HWA decoder for OpenCV using GST use cases
ENV OPENCV_FFMPEG_CAPTURE_OPTIONS="hw_decoders_any;vaapi"

ENTRYPOINT ["/bin/bash", "-c"]
