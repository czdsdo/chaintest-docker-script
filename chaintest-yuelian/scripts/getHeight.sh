#!/bin/bash
function getHeight(){
    RESULT=$(curl -X GET -i 'http://119.27.168.192:9999/getheight')
    SUCCESS=$(echo $RESULT | jq ".Message" | sed "s/\"//g")
    if [ $SUCCESS == "success" ]
    then
        HEIGHT=$(echo $RESULT | jq ".Date" | sed "s/\"//g")
        echo $HEIGHT > /height
    else
        return
    fi
}

while [ 1 ]
do
sleep 1s
getHeight
done
