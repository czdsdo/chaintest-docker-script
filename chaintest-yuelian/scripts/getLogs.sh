#!/bin/bash
# author:wang yi
echo 1 > /logsnow
echo 1 > /logsheight
echo 0 > /logsnumber
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
    echo  /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log > /chain/LOGNAME

    # LOGSHEIGHT=$(cat /logsheight)
    # LOGSNOW=$(cat /logsnow)
    # LOGSNUMBER=$(cat /logsnumber)

    # if test $[LOGSNOW] -ge $[LOGSHEIGHT]
    # then 
    # return
    # fi

    # # LOGSTEMP=`expr $LOGSNOW + 1`
    # LOGSTEMP=$LOGSNOW
    # if test $[LOGSTEMP] -lt $[LOGSHEIGHT]
    # then
    # sed -n "$LOGSNOW,$LOGSTEMP p" /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log > /chain/data/dockerlogs
    # LOGSNOW=`expr $LOGSTEMP + 1`
    # else
    # sed -n "$LOGSNOW,$LOGSHEIGHT p" /var/lib/docker/containers/$CONTAINER_ID/$CONTAINER_ID-json.log > /chain/data/dockerlogs
    # LOGSNOW=`expr $LOGSHEIGHT + 1`
    # fi
    # echo $LOGSNOW > /logsnow
    
    # A=$(cat /chain/data/dockerlogs)
    # if [ -z "$A" -o "$A" = " " ]; then
    #     return
    # else
    #     cat /chain/data/dockerlogs > /chain/data/finallogs$LOGSNUMBER
    #     NEW=`expr $LOGSNUMBER + 1`
    #     echo $NEW > /logsnumber
    # fi
}
# while [ 1 ]
# do
# sleep 10s
# getLogs
# done