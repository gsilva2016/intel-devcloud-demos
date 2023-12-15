#!/bin/bash
#
# Copyright (C) 2023 Intel Corporation.
#
# SPDX-License-Identifier: Apache-2.0
#

cid_count=0
pid_count=0
pid_count2=1

# change pre_process="" if using USB or RealSense cameras
pre_process="pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1"

# User configured parameters
#INPUTSRC="filesrc location=/vids/myvideo.mp4 ! qtdemux ! h264parse "
#INPUTSRC="v4l2src device=/dev/video0 ! videoconvert ! video/x-raw,format=BGR "
INPUTSRC="rtsp://127.0.0.1:8554/camera_0 ! rtph264depay "
INPUTSRC2="rtsp://127.0.0.1:8554/camera_0 ! rtph264depay "


if [ "1" == "$LOW_POWER" ]
then
	echo "Enabled GPU based low power pipeline "
	
	gst-launch-1.0 \
	$INPUTSRC ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification $pre_process ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=false --verbose \
	$INPUTSRC2 ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification2 $pre_process ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=false --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)
elif [ "$RENDER_MODE" == "1" ]
then
	echo "Launching rendered pipeline"
	gst-launch-1.0 \
	$INPUTSRC ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification $pre_process ! gvametaconvert name=metaconvert add-empty-results=true ! vaapipostproc ! gvawatermark ! videoconvert ! fpsdisplaysink video-sink=autovideosink sync=false --verbose \
	$INPUTSRC2 ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification2 $pre_process ! gvametaconvert name=metaconvert2 add-empty-results=true ! vaapipostproc ! gvawatermark ! videoconvert ! fpsdisplaysink video-sink=autovideosink sync=false --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)

elif [ "$CPU_ONLY" == "1" ] 
then
	echo "Enabled CPU inference pipeline only"
	gst-launch-1.0 \
	$INPUTSRC ! decodebin force-sw-decoders=1 ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=CPU ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=CPU inference-region=roi-list name=classification ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	$INPUTSRC2 ! decodebin force-sw-decoders=1 ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=CPU ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=CPU inference-region=roi-list name=classification2 ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)

else
	echo "Enabled CPU+iGPU pipeline"
	gst-launch-1.0 \
	$INPUTSRC ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification $pre_process ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=false --verbose \
	$INPUTSRC2 ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=CPU inference-region=roi-list name=classification2 ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=false --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)
fi
