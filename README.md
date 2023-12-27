# Intel Devcloud Demos
Intel DevCloud Media and AI demos


## Build Steps

1. Download the quantized yolov8 IR model

```
./download-yolov8.sh
```

2. Build GST + OVMS Docker Images

```
sudo docker build -t devcloud-demo-ovms:1.0 -f Dockerfile.ovms .
```

3. Run GST + OVMS E2E Pipeline Examples

**Environment variables. Note not all are shown below for brevity**

_Used to show direct console output_
DC=1 

_Video streams' location and types_
INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
INPUTSRC2=rtsp://127.0.0.1:8554/camera_0 
INPUT_TYPE=RTSP_H264
INPUT_TYPE2=RTSP_H264

_Rendering_
RENDER_MODE=0 # enable rendering graphical content in a window
RENDER_PORTRAIT_MODE=0 # landscape vs. portrait rendering

_Pipelines_
LOW_POWER=1  # GPU  pipeline
CPU_ONLY=0   # CPU  pipeline
LOW_POWER=0 && CPU_ONLY=0 # CPU+GPU pieline


**Yolov8 Dual Camera GPU Example**

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
INPUTSRC2=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=0
RENDER_PORTRAIT_MODE=0
LOW_POWER=1
CPU_ONLY=0
INPUT_TYPE=RTSP_H264
INPUT_TYPE2=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e INPUTSRC2=$INPUTSRC2 -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms:1.0 yolov8_ensemble/yolo_efficientnet_dual.sh



**Yolov8 Dual Camera CPU+GPU Example**

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
INPUTSRC2=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=0
RENDER_PORTRAIT_MODE=0
LOW_POWER=0
CPU_ONLY=0
INPUT_TYPE=RTSP_H264
INPUT_TYPE2=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e INPUTSRC2=$INPUTSRC2 -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms:1.0 yolov8_ensemble/yolo_efficientnet_dual.sh


**Yolov8 Single Camera CPU with Rendering Example**

xhost +

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=1
RENDER_PORTRAIT_MODE=0
LOW_POWER=0
CPU_ONLY=1
INPUT_TYPE=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms:1.0 yolov8_ensemble/yolo_efficientnet.sh
