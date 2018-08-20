#!/bin/sh	
# author:wang yi
PEER_INDEX=$1
IP_P0O1=$2
IP_P1O1=$3
IP_P2O1=$4
IP_P3O1=$5
IP_P4O1=$6
echo $PEER_INDEX > /chain/PEER_INDEX
echo $IP_P0O1 > /chain/IP_P0O1
echo $IP_P1O1 > /chain/IP_P1O1
echo $IP_P2O1 > /chain/IP_P2O1
echo $IP_P3O1 > /chain/IP_P3O1
echo $IP_P4O1 > /chain/IP_P4O1

#PEER_INDEX1=`expr $PEER_INDEX - 2`
function chooseScript(){
    case $PEER_INDEX in
       
        1|2|3|4|5)  {
            sleep $PEER_INDEX
            source /etc/profile
            sudo chmod +x  /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/peer
            cd /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer
           # ./peer init
        }
        ;;
        *)  echo 'error'
        ;;
    esac
}
function configConfigJson(){
    case $PEER_INDEX in
       
        1)  {
             sed -i "s/IP_self/$IP_P0O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
             sed -i "s/IP_num/$PEER_INDEX/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
        }
        ;;
        2)  {
             sed -i "s/IP_self/$IP_P1O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
             sed -i "s/IP_num/$PEER_INDEX/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
        }
        ;;
        3)  {
             sed -i "s/IP_self/$IP_P2O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
             sed -i "s/IP_num/$PEER_INDEX/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
        }
        ;;
        4)  {
             sed -i "s/IP_self/$IP_P3O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
             sed -i "s/IP_num/$PEER_INDEX/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
        }
        ;;
        5)  {
             sed -i "s/IP_self/$IP_P4O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
             sed -i "s/IP_num/$PEER_INDEX/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
        }
        ;;
        *)  echo 'error'
        ;;
    esac
    sed -i "s/IP_P0O1/$IP_P0O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
    sed -i "s/IP_P1O1/$IP_P1O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
    sed -i "s/IP_P2O1/$IP_P2O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
    sed -i "s/IP_P3O1/$IP_P3O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
    sed -i "s/IP_P4O1/$IP_P4O1/g" /chain/chaintest-docker-script/chaintest-yuelian/wutong/peer/config.yaml
}
sleep 1s
configConfigJson >/dev/null 2>&1
sleep 1s
chooseScript >/dev/null 2>&1
echo "success"