#!/bin/bash
# author:wang yi

# 本地docker仓库IP
REGISTRY="172.16.7.10:5000"
# 配置本地仓库，允许insecure-registries
if [ ! -f "/etc/docker/daemon.json" ]; then
    touch /etc/docker/daemon.json
fi
DAEMON=$(cat /etc/docker/daemon.json | grep "$REGISTRY")
if [ -z "$DAEMON" -o "$DAEMON" = " " ]; then
    echo "{\"insecure-registries\": [\"$REGISTRY\"]}" >/etc/docker/daemon.json
    service docker restart
fi

#关闭已开启zabbix容器
function stopExistsContainers(){
    CONTAINER_ID=$(docker ps -a | grep "zabbix-" | awk '{print $1}')
        if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
                docker rm -f $CONTAINER_ID
        fi
}
#检查镜像是否存在
function checkZabbixServer(){
	DOCKER_IMAGE_ID=$(docker images | grep "mysql" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
		    docker pull $REGISTRY/mysql:5.7
            docker tag $REGISTRY/mysql:5.7 mysql:5.7
            docker rmi $REGISTRY/mysql:5.7
        fi
    DOCKER_IMAGE_ID=$(docker images | grep "zabbix-java-gateway" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
		    docker pull $REGISTRY/zabbix-java-gateway:latest
            docker tag $REGISTRY/zabbix-java-gateway:latest zabbix-java-gateway:latest
            docker rmi $REGISTRY/zabbix-java-gateway:latest
        fi
    DOCKER_IMAGE_ID=$(docker images | grep "zabbix-server-mysql" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
		    docker pull $REGISTRY/zabbix-server-mysql:latest
            docker tag $REGISTRY/zabbix-server-mysql:latest zabbix-server-mysql:latest
            docker rmi $REGISTRY/zabbix-server-mysql:latest
        fi
    DOCKER_IMAGE_ID=$(docker images | grep "zabbix-web-nginx-mysql" | awk '{print $3}')
        if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
		    docker pull $REGISTRY/zabbix-web-nginx-mysql:latest
            docker tag $REGISTRY/zabbix-web-nginx-mysql:latest zabbix-web-nginx-mysql:latest
            docker rmi $REGISTRY/zabbix-web-nginx-mysql:latest
        fi
}
# 启动服务
function startZabbixServer(){
    #检查镜像是否存在
    checkZabbixServer
    #关闭已开启zabbix容器
    stopExistsContainers
    #启动mysql容器
    docker run --name zabbix-mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -p 3306:3306 \
      -v /etc/localtime:/etc/localtime:ro \
      -d mysql:5.7 \
      --character-set-server=utf8 --collation-server=utf8_bin
    #暂停5秒
    sleep 5s
    #启动zabbix-java-gateway容器
    docker run --name zabbix-java-gateway -t \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix-java-gateway:latest
    #暂停5秒
    sleep 5s
    #启动zabbix-server-mysql容器
    docker run --name zabbix-server-mysql -t \
      -e DB_SERVER_HOST="zabbix-mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --link zabbix-mysql-server:mysql \
      --link zabbix-java-gateway:zabbix-java-gateway \
      -p 10051:10051 \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix-server-mysql:latest
    #暂停5秒
    sleep 5s
    #启动zabbix-web-nginx-mysql容器
    docker run --name zabbix-web-nginx-mysql -t \
      -e DB_SERVER_HOST="zabbix-mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -e ZBX_TIMEOUT=30 \
      --link zabbix-mysql-server:mysql \
      --link zabbix-server-mysql:zabbix-server \
      -p 10080:80 \
      -v /etc/localtime:/etc/localtime:ro \
      -d zabbix-web-nginx-mysql:latest
}
#启动
startZabbixServer