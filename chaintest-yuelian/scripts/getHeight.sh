#!/bin/bash
function getHeight(){
    RESULT=$(curl -s 'http://119.27.168.192:9999/getheight')
    SUCCESS=$(echo $RESULT | jq ".Message" | sed "s/\"//g")
    if [ $SUCCESS == "success" ]
    then
        HEIGHT=$(echo $RESULT | jq ".Data" | sed "s/\"//g")
        echo $HEIGHT > /height
        cat /height
    else
        return
    fi
}

while [ 1 ]
do
sleep 1s
getHeight
done