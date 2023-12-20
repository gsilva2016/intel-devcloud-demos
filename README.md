# intel-devcloud-demos
Intel DevCloud Media and AI demos


Yolov8 Dual Camera GPU Example

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
INPUTSRC2=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=0
RENDER_PORTRAIT_MODE=0
LOW_POWER=1
CPU_ONLY=0
INPUT_TYPE=RTSP_H264
INPUT_TYPE2=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e INPUTSRC2=$INPUTSRC2 -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms-1.0 yolov8_ensemble/yolo_efficientnet_dual.sh



Yolov8 Dual Camera CPU+GPU Example

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
INPUTSRC2=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=0
RENDER_PORTRAIT_MODE=0
LOW_POWER=0
CPU_ONLY=0
INPUT_TYPE=RTSP_H264
INPUT_TYPE2=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e INPUTSRC2=$INPUTSRC2 -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms-1.0 yolov8_ensemble/yolo_efficientnet_dual.sh


Yolov8 Single Camera CPU with Rendering Example

xhost +

INPUTSRC=rtsp://127.0.0.1:8554/camera_0 
RENDER_MODE=1
RENDER_PORTRAIT_MODE=0
LOW_POWER=0
CPU_ONLY=1
INPUT_TYPE=RTSP_H264


docker run --rm --user root -it -e INPUTSRC=$INPUTSRC -e RENDER_MODE=$RENDER_MODE -e LOW_POWER=$LOW_POWER -e CPU_ONLY=$CPU_ONLY -e INPUT_TYPE=$INPUT_TYPE -e INPUT_TYPE2=$INPUT_TYPE2 -v /tmp/.X11-unix:/tmp/.X11-unix -v `pwd`/tmp:/app/yolov8_ensemble/results -v `pwd`:/savedir --net host --ipc=host --device /dev/dri/renderD128 devcloud-demo-ovms-1.0 yolov8_ensemble/yolo_efficientnet.sh
