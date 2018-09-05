#!/bin/bash
# author:wang yi
#根据不同测评实例，修改
#getEvalExample(由被测对象提供获取区块链方法)
#configEvalScript(测评系统根据被测对象提供的方法进行包装)

#参数传入zabbix server ip
SERVER_IP="172.27.0.6"
SERVER_IP_PORT="172.27.0.6:90"
#zabbix agent ip
#AGENT_IP=`ifconfig  | grep 'inet addr:' | grep -v '127.0.0.1' | grep -v '0.0.0.0' | grep -v '172.17.' | cut -d: -f2 | awk '{ print $1}'`
AGENT_IP=`ifconfig | grep 'inet addr:172.27' | cut -d: -f2 | awk '{ print $1}'`

# #docker本地仓库
REGISTRY="172.27.0.6:5000"


# zabbix-agent                latest              caf94e94ebd8        2 days ago          561 MB
# eval-init                   latest              845a3351fe45        3 weeks ago         256 MB
# eval                        latest              480b58403db9        3 weeks ago         755 MB
# fabric-orderer              v1.0.0              e317ca5638ba        5 months ago        179 MB
# fabric-peer                 v1.0.0              6830dcd7b9b5        5 months ago        182 MB
# hyperledger/fabric-ccenv    x86_64-1.0.0        7182c260a5ca        5 months ago        1.29 GB
# fabric-ca                   v1.0.0              a15c59ecda5b        5 months ago        238 MB
# hyperledger/fabric-baseos   x86_64-0.3.1        4b0cab202084        7 months ago        157 MB

if [ ! -f "/etc/docker/daemon.json" ]; then
    touch /etc/docker/daemon.json
fi
DAEMON=$(cat /etc/docker/daemon.json | grep "$REGISTRY")
if [ -z "$DAEMON" -o "$DAEMON" = " " ]; then
    echo "{\"insecure-registries\": [\"$REGISTRY\"]}" >/etc/docker/daemon.json
    service docker restart
fi

#创建/chain/data目录
if [ ! -d "/chain/data" ]; then
  mkdir -p /chain/data
fi
#创建/chain/data/netdat文件
if [ ! -f "/chain/data/netdat" ]; then
    touch /chain/data/netdat
fi
#保存IP
echo $SERVER_IP > /chain/SERVER_IP
echo $AGENT_IP > /chain/AGENT_IP
#执行网络监控
function startNetItem(){
    #获得网卡名称
    ETH_ID=$(ifconfig -s | awk '{print $1}' | grep "^e")
    #后台运行tcpdump，监控网卡，并将结果输出至/chain/data/netdat
    nohup tcpdump -qtn  -i $ETH_ID 'tcp port not 22 and port not 10050 and port not 10051 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)' > /chain/data/netdat 2>&1 &
}
#启动并初始化zabbix-agent
function startZabbixAgent(){
    #关掉已存在zabbix-agent容器
    # CONTAINER_ID=$(docker ps -a | grep "zabbix-agent" | awk '{print $1}')
    #     if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
    #             docker rm -f $CONTAINER_ID 
    #     fi
    #启动zabbix-agent容器
    docker run --privileged=true \
    --restart=always \
    --name zabbix-agent \
    --network=host \
    -e ZBX_HOSTNAME=$AGENT_IP \
    -e ZBX_SERVER_PORT=10051 \
    -e ZBX_SERVER_HOST=$SERVER_IP \
    -e ZBX_UNSAFEUSERPARAMETERS=1 \
    -e ZBX_ENABLEREMOTECOMMANDS=1 \
    -e ZBX_TIMEOUT=30 \
    -v /dev/sdc:/dev/sdc \
    -v /chain:/chain \
    -v /home/ubuntu/chaintest-docker-script:/home/ubuntu/chaintest-docker-script \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker:/var/lib/docker \
    -d zabbix-agent:latest
    #暂停10s
    sleep 10s
    #初始化agent
#      docker run --rm --privileged=true \
#     --network=host \
#     eval-init:latest 
    /bin/bash /chain/scripts/init.sh $SERVER_IP_PORT $AGENT_IP
}
#获取及配置区块链
function getEvalExample(){
    # #下载需要镜像
    # #下载最新zabbix-agent、agent初始化镜像
    #  docker pull $REGISTRY/zabbix-agent-wutong:new
    #  docker rmi zabbix-agent:latest
    #  docker tag $REGISTRY/zabbix-agent-wutong:new zabbix-agent:latest
    #  docker rmi $REGISTRY/zabbix-agent-wutong:new
    docker pull $REGISTRY/zabbix-agent:new
    docker rmi zabbix-agent:latest
    docker tag $REGISTRY/zabbix-agent:new zabbix-agent:latest
    docker rmi $REGISTRY/zabbix-agent:new
 
    
    # #安装git、tcpdump
    # apt-get update 
    # apt-get install -y -qq git tcpdump
    #git克隆工程
    cd /chain
    git clone -b dev.wutong https://gitee.com/czdyxs/chaintest-docker-script.git
    #git clone -b  https://gitee.com/wangyi0559/tchaintest-yuelian.git
    #移动需要文件
    mv /chain/chaintest-docker-script/chaintest-yuelian/wutong/config/config.yaml /chain/config.yaml 
    mv /chain/chaintest-docker-script/chaintest-yuelian/wutong/config/channel /chain/channel 
    mv /chain/chaintest-docker-script/chaintest-yuelian/scripts /chain/scripts

    # rm /home/test/go/src/mongo-chaintesting/main.go
    # mv /chain/scripts/main.go /home/test/go/src/mongo-chaintesting

    #docker 网络配置
    NETWORK_ID=$(docker network ls | grep "artifacts_default" | awk '{print $1}')
        if [ -z "$NETWORK_ID" -o "$NETWORK_ID" = " " ]; then
            docker network create -d bridge --ipv6=false artifacts_default 
        fi 
}
#配置相关执行脚本
function configEvalScript(){
    #/chain/Create.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/Create.sh /chain/Create.sh
    cp /chain/Create.sh /chain/CreateTaskCommand.sh
    #/chain/Init.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/Init.sh /chain/Init.sh
    cp /chain/Init.sh /chain/InitTaskCommand.sh
    #/chain/SendTransaction.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/SendTransaction.sh /chain/SendTransaction.sh
    cp /chain/SendTransaction.sh /chain/SendTransactionTaskCommand.sh
    #/chain/ChangeStatus.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/ChangeStatus.sh /chain/ChangeStatus.sh
    cp /chain/ChangeStatus.sh /chain/ChangeStatusTaskCommand.sh
    #/chain/DisConnection.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/DisConnection.sh /chain/DisConnection.sh
    cp /chain/DisConnection.sh /chain/DisConnectionTaskCommand.sh
    #/chain/AssConnection.sh
    mv /chain/chaintest-docker-script/chaintest-yuelian/AssConnection.sh /chain/AssConnection.sh
    cp /chain/AssConnection.sh /chain/AssConnectionTaskCommand.sh
}

sleep 1s
#获取及配置区块链
getEvalExample >/dev/null 2>&1
sleep 1s
#配置相关执行脚本
configEvalScript >/dev/null 2>&1
sleep 1s
#启动并初始化zabbix-agent
startZabbixAgent >/dev/null 2>&1
sleep 1s
#执行网络监控
startNetItem >/dev/null 2>&1

sleep 5s
# source /etc/profile
# OLDGOPATH="$GOPATH"
# export GOPATH="/home/test/go"
# cd /home/test/go/src/mongo-chaintesting
# /usr/local/go/bin/go build 
# sleep 1s
# #nohup /home/test/go/src/mongo-chaintesting/mongo-chaintesting > /dev/null 2>&1 &
# export GOPATH="$OLDGOPATH"
