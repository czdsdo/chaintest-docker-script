#!/bin/bash
#author:chen xu
# 本地docker仓库IP:5000
Server_IP=`ifconfig | grep 'inet addr:172.27' | cut -d: -f2 | awk '{ print $1}'`
REGISTRY=${Server_IP}":5000"
echo $REGISTRY
function startDockerRegistry(){
    sudo docker pull registry
    sudo mkdir –p /opt/registry/auth/
    docker run --entrypoint htpasswd registry -Bbn hoopox hoopox1616 >> /opt/registry/auth/htpasswd
    docker run -d -p 5000:5000 --restart=always \
    --name=registry \
    -v /opt/registry:/var/lib/registry \
    -v /opt/registry/auth/:/auth/ \
    registry
if [ ! -f "/etc/docker/daemon.json" ]; then
    touch /etc/docker/daemon.json
fi
DAEMON=$(cat /etc/docker/daemon.json | grep "$REGISTRY")
if [ -z "$DAEMON" -o "$DAEMON" = " " ]; then
    echo "{\"insecure-registries\": [\"$REGISTRY\"]}" >/etc/docker/daemon.json
    service docker restart
fi  
}
#拉取镜像
function pullDockerimages(){
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-java-gateway:latest
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-server-mysql:latest
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-web-nginx-mysql:latest
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-gent:latest
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/mysql:5.7
    sudo docker pull registry.cn-hangzhou.aliyuncs.com/chenxu1015/mongo:3.6
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-java-gateway:latest zabbix-java-gateway:latest
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-server-mysql:latest  zabbix-server-mysql:latest
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-web-nginx-mysql:latest zabbix-web-nginx-mysql:latest
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-gent:latest  zabbix-agent:latest
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/mysql:5.7 mysql:5.7
    sudo docker tag registry.cn-hangzhou.aliyuncs.com/chenxu1015/mongo:3.6 mongo:3.6
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-java-gateway:latest
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-server-mysql:latest
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-web-nginx-mysql:latest
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/zabbix-gent:latest
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/mysql:5.7
    sudo docker rmi registry.cn-hangzhou.aliyuncs.com/chenxu1015/mongo:3.6
}
#推送zabbix-agent至仓库
function pushDockerimages(){
    sudo docker tag zabbix-agent:latest $REGISTRY/zabbix-agent:latest
    sudo docker push $REGISTRY/zabbix-agent:latest
    sudo docker rmi $REGISTRY/zabbix-agent:latest

    sudo docker tag zabbix-java-gateway:latest $REGISTRY/zabbix-java-gateway:latest 
    sudo docker tag zabbix-server-mysql:latest $REGISTRY/zabbix-server-mysql:latest  
    sudo docker tag zabbix-web-nginx-mysql:latest $REGISTRY/zabbix-web-nginx-mysql:latest 
    sudo docker tag zabbix-agent:latest $REGISTRY/zabbix-gent:latest 
    sudo docker tag mysql:5.7 $REGISTRY/mysql:5.7 
    sudo docker tag mongo:3.6 $REGISTRY/mongo:3.6
    sudo docker push $REGISTRY/zabbix-java-gateway:latest
    sudo docker push $REGISTRY/zabbix-server-mysql:latest
    sudo docker push $REGISTRY/zabbix-web-nginx-mysql:latest
    sudo docker push $REGISTRY/zabbix-gent:latest
    sudo docker push $REGISTRY/mysql:5.7
    sudo docker push $REGISTRY/mongo:3.6
    sudo docker rmi $REGISTRY/zabbix-java-gateway:latest
    sudo docker rmi $REGISTRY/zabbix-server-mysql:latest
    sudo docker rmi $REGISTRY/zabbix-web-nginx-mysql:latest
    sudo docker rmi $REGISTRY/zabbix-gent:latest
    sudo docker rmi $REGISTRY/mysql:5.7
    sudo docker rmi $REGISTRY/mongo:3.6
    
    
}
startDockerRegistry
pullDockerimages
pushDockerimages