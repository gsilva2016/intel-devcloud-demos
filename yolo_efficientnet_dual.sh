#!/bin/bash
#
# Copyright (C) 2023 Intel Corporation.
#
# SPDX-License-Identifier: Apache-2.0
#


pre_process=""
INPUTSRC="rtsp://127.0.0.1:8554"
INPUTRSRC2="rtsp://127.0.0.1:8554"
# INPUTSRC="file:video.mp4"
# INPUTSRC="/dev/video0"

INPUT_DEPAY="rtph264depay"
INPUT_DEPAY2="rtph264depay"

if grep -q "rtsp" <<< "$INPUTSRC"; then
	# rtsp
	inputsrc=$INPUTSRC" ! $INPUT_DEPAY "
	inputsrc2=$INPUTSRC2" ! $INPUT_DEPAY2 "
	INPUTSRC_TYPE="RTSP"
	pre_process="pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1"

elif grep -q "file" <<< "$INPUTSRC"; then
	# filesrc	
	arrfilesrc=(${INPUTSRC//:/ })
	# use vids since container maps a volume to this location based on sample-media folder
	# TODO: need to pass demux/codec info
	inputsrc="filesrc location=vids/"${arrfilesrc[1]}" ! qtdemux ! h264parse "
	INPUTSRC_TYPE="FILE"
	decode_type="vaapidecodebin"
	pre_process="pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1"

elif grep -q "video" <<< "$INPUTSRC"; then
	# v4l2src /dev/video*
	# TODO need to pass stream info
	inputsrc="v4l2src device="$INPUTSRC
	INPUTSRC_TYPE="USB"
	TARGET_USB_DEVICE="--device=$INPUTSRC"
	decode_type="videoconvert ! video/x-raw,format=BGR"
	pre_process=""

# else
# 	# rs-serial realsenssrc
# 	# TODO need to pass depthalign info
# 	inputsrc="realsensesrc cam-serial-number="$INPUTSRC" stream-type=0 align=0 imu_on=false"
#     # add realsense color related properties if any
# 	if [ "$COLOR_WIDTH" != 0 ]; then
# 		inputsrc=$inputsrc" color-width="$COLOR_WIDTH
# 	fi
# 	if [ "$COLOR_HEIGHT" != 0 ]; then
# 		inputsrc=$inputsrc" color-height="$COLOR_HEIGHT
# 	fi
# 	if [ "$COLOR_FRAMERATE" != 0 ]; then
# 		inputsrc=$inputsrc" color-framerate="$COLOR_FRAMERATE
# 	fi
# 	INPUTSRC_TYPE="REALSENSE"
# 	decode_type="decodebin ! videoconvert ! video/x-raw,format=BGR"
# 	pre_process=""
# 	cameras=`ls /dev/vid* | while read line; do echo "--device=$line"; done`
# 	TARGET_GPU_DEVICE=$TARGET_GPU_DEVICE" "$cameras	
fi

# if [ "$INPUTSRC_TYPE" == "REALSENSE" ]; then
#     decode_pp="! videoconvert ! video/x-raw,format=BGR"
# 	# TODO: update with vaapipostproc when MJPEG codec is supported.
#     echo "Not supported until D436 with MJPEG." > /app/dlstreamer/results/pipeline$cid_count.log
#     exit 0
# fi

cid_count=0
pid_count=0
pid_count2=1

if [ "1" == "$LOW_POWER" ]
then
	echo "Enabled GPU based low power pipeline "
	#gst-launch-1.0 \
#rtspsrc location=rtsp://127.0.0.1:8554/camera_0 ! rtph264depay ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP16-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1 ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1 ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r0.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
#rtspsrc location=rtsp://127.0.0.1:8554/camera_0 ! rtph264depay ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP16-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1 ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification2 pre-process-backend=vaapi-surface-sharing pre-process-config=VAAPI_FAST_SCALE_LOAD_FACTOR=1 ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r1.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose

	gst-launch-1.0 \
	$inputsrc ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification $pre_process ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	$inputsrc2 ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification2 $pre_process ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)
elif [ "$RENDER_MODE" == "1" ]
then
	echo "Launching rendered pipeline"
	gst-launch-1.0 \
	$inputsrc ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification $pre_process ! gvametaconvert name=metaconvert add-empty-results=true ! vaapipostproc ! gvawatermark ! videoconvert ! fpsdisplaysink video-sink=autovideosink sync=false --verbose \
	$inputsrc ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=GPU $pre_process ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=GPU inference-region=roi-list name=classification2 $pre_process ! gvametaconvert name=metaconvert2 add-empty-results=true ! vaapipostproc ! gvawatermark ! videoconvert ! fpsdisplaysink video-sink=autovideosink sync=false --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)

elif [ "$CPU_ONLY" == "1" ] 
then
	echo "Enabled CPU inference pipeline only"
	gst-launch-1.0 \
	$inputsrc ! decodebin force-sw-decoders=1 ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=CPU ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=CPU inference-region=roi-list name=classification ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	$inputsrc ! decodebin force-sw-decoders=1 ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=CPU ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=CPU inference-region=roi-list name=classification2 ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)

else
	echo "Enabled CPU+iGPU pipeline"
	gst-launch-1.0 \
	$inputsrc ! vaapidecodebin ! gvadetect model-instance-id=odmodel name=detection model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=MULTI:GPU,CPU ! gvaclassify model-instance-id=clasifier labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=MULTI:GPU,CPU inference-region=roi-list name=classification ! gvametaconvert name=metaconvert add-empty-results=true ! gvametapublish name=destination file-format=2 file-path=/app/dlstreamer/results/r$pid_count.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	$inputsrc ! vaapidecodebin ! gvadetect model-instance-id=odmodel2 name=detection2 model=models/yolov5s/1/FP32-INT8/yolov5s.xml model-proc=models/yolov5s/1/yolov5s.json threshold=.5 device=MULTI:GPU,CPU ! gvaclassify model-instance-id=clasifier2 labels=models/efficientnet-b0/1/imagenet_2012.txt model=models/efficientnet-b0/1/FP16-INT8/efficientnet-b0.xml model-proc=models/efficientnet-b0/1/efficientnet-b0.json device=MULTI:GPU,CPU inference-region=roi-list name=classification2 ! gvametaconvert name=metaconvert2 add-empty-results=true ! gvametapublish name=destination2 file-format=2 file-path=/app/dlstreamer/results/r$pid_count2.jsonl ! fpsdisplaysink video-sink=fakesink sync=true --verbose \
	2>&1 | tee >/app/dlstreamer/results/gst-launch_core_$cid_count.log >(stdbuf -oL sed -n -e 's/^.*current: //p' | stdbuf -oL cut -d , -f 1 > /app/dlstreamer/results/pipeline$cid_count.log)
fi
