#!/bin/sh	
# author:wang yi

function startSDK(){
    # #删除已有同名容器
    # CONTAINER_ID=$(docker ps -a | grep "fabric-sdk" | awk '{print $1}')
    #     if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
    #         docker rm -f $CONTAINER_ID 
    #     fi  
    #启动 
    docker run -d \
	-v /chain/channel/:/home/Service/test/artifacts/channel/ \
	-v /chain/config.json:/home/Service/test/config.json \
	--network=host \
    --restart=always \
	--name fabric-sdk eval:latest 
}
startSDK >/dev/null 2>&1
echo "success"