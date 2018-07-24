#!/bin/bash
# author:wang yi
echo 1 > /logsnow
echo 1 > /logsheight
> /chain/data/finallogs

function getLogs(){
    STATUS=$(cat /status)
    if [ $STATUS == "0" ]; then
        return
    fi
    if [ ! -f "/chain/CONTAINER_ID" ]; then
        return 
    fi
    CONTAINER_ID=$(cat /chain/CONTAINER_ID)
    sed -n '$=' /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log > /logsheight

    LOGSHEIGHT=$(cat /logsheight)
    LOGSNOW=$(cat /logsnow)

    if test $[LOGSNOW] -ge $[LOGSHEIGHT]
    then 
    return
    fi
    LOGSTEMP=`expr $LOGSNOW + 5000`
    if test $[LOGSTEMP] -lt $[LOGSHEIGHT]
    then
    sed -n "$LOGSNOW,$LOGSTEMP p" /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log | sed -e 's/^{"log":"//' | sed 's/..$//' | sed -e 's/\\u001b\[[0-9]\{0,\}m//g' | sed -e 's/\\u003e/>/g' > /chain/data/dockerlogs
    LOGSNOW=`expr $LOGSTEMP + 1`
    else
    sed -n "$LOGSNOW,$LOGSHEIGHT p" /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log | sed -e 's/^{"log":"//' | sed 's/..$//' | sed -e 's/\\u001b\[[0-9]\{0,\}m//g' | sed -e 's/\\u003e/>/g' > /chain/data/dockerlogs
    LOGSNOW=`expr $LOGSHEIGHT + 1`
    fi
    echo $LOGSNOW > /logsnow
    cat /chain/data/dockerlogs | grep -E '(Starting new Broadcast handler|Closing Broadcast stream)' > /chain/data/BroadcastTime
    cat /chain/data/dockerlogs | grep -E '(Adding payload locally,|\[chaincode\] Execute -> .* Exit)' | grep -A 1 'Adding payload locally,' > /chain/data/TransactionTime
    A=$(cat /chain/data/BroadcastTime)
    B=$(cat /chain/data/TransactionTime)
    if [ -z "$A" -o "$A" = " " ] && [ -z "$B" -o "$B" = " " ]; then
        return
    else
        cat /chain/data/BroadcastTime >> /chain/data/finallogs
        cat /chain/data/TransactionTime >> /chain/data/finallogs
    fi
}
while [ 1 ]
do
sleep 5s
getLogs
done