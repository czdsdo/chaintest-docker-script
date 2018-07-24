#!/bin/bash
# author:wang yi
function getBlock(){
    HEIGHT=$(cat /height)
    NOW=$(cat /now)
    if test $[NOW] -lt $[HEIGHT]
    then
        NEW=`expr $NOW + 1`
        BLOCK_ID=$NOW
        RESULT=$(curl -s 127.0.0.1:8080/api/getInfo?blockId=$BLOCK_ID)
        echo $RESULT >> /chain/data/finalblock$NOW
        echo $NEW > /now
    else
        sleep 1s
        return
    fi
}
while [ 1 ]
do
#sleep 1s
getBlock
done

# echo '111' >> /chain/finalblock0