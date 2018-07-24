#!/bin/bash
AGENT_IP=$(cat /chain/AGENT_IP)
> /chain/data/finalnet
function getNet(){
    cp /chain/data/netdat /chain/data/netdat1
    >/chain/data/netdat
    sed -i '1d;$d' /chain/data/netdat1
    awk '{ $1=null;$3=null;$5=null;print }' /chain/data/netdat1 > /chain/data/netdat2
    awk '{a[$1" "$2]+=$3;}END{for (i in a) print i,a[i];}' /chain/data/netdat2>/chain/data/netdat3
    sed -i -e "/$AGENT_IP/!d" /chain/data/netdat3
    sed -i "s/$AGENT_IP//g" /chain/data/netdat3
    A=$(cat /chain/data/netdat3)
    if [ -z "$A" -o "$A" = " " ]; then
        rm /chain/data/netdat1
        return
    fi
    cat /chain/data/netdat3 >> /chain/data/finalnet
    rm /chain/data/netdat1
}
while [ 1 ]
do
sleep 3s
getNet
done