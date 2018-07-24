#!/bin/bash

> /chain/data/finaldisk

function getDisk(){
    STATUS=$(cat /status)
    if [ $STATUS == "0" ]; then
        return
    fi
    if [ ! -f "/chain/CONTAINER_ID" ]; then
        return
    fi
    docker ps -f id=`cat /chain/CONTAINER_ID` -s | sed '1d' |  awk -F'  +' '{print $8}' > /chain/data/finaldisk
}

while [ 1 ]
do
sleep 8s
getDisk
done
