#!/bin/sh	
# author:wang yi

#启动
function startCA1(){
    #删除已有同名容器
    # CONTAINER_ID=$(docker ps -a | grep "ca_peerOrg1" | awk '{print $1}')
    #     if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
    #         docker rm -f $CONTAINER_ID 
    #     fi    
    #启动  
    docker run -d \
	--restart=always \
	-e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server \
	-e FABRIC_CA_SERVER_CA_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem \
	-e FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/64aec7d9cf5863bb1cb815a8c7654ed5ce06b153bec1df93240cbedeadf0ea93_sk \
	-e FABRIC_CA_SERVER_TLS_ENABLED=true \
	-e FABRIC_CA_SERVER_TLS_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem \
	-e FABRIC_CA_SERVER_TLS_KEYFILE=/etc/hyperledger/fabric-ca-server-config/64aec7d9cf5863bb1cb815a8c7654ed5ce06b153bec1df93240cbedeadf0ea93_sk \
	-p 7054:7054 \
    -e CORE_LOGGING_LEVEL=CRITICAL  \
    --network=artifacts_default \
	--privileged=true \
	-v /chain/channel/crypto-config/peerOrganizations/org1.example.com/ca/:/etc/hyperledger/fabric-ca-server-config \
	--name ca_peerOrg1 \
	fabric-ca:v1.0.0 \
	sh -c 'fabric-ca-server start -b admin:adminpw -d' 
}
startCA1 >/dev/null 2>&1
sleep 1s
echo "ca_peerOrg1" > /chain/CONTAINER_NAME
ls /var/lib/docker/containers | grep `docker ps -a | grep "ca_peerOrg1" | awk '{print $1}'` > /chain/CONTAINER_ID
echo "success"