#!/bin/bash

# DNS设置
DNS=$(cat /etc/network/interfaces | grep dns-nameservers)
if [ -z "$DNS" -o "$DNS" = " " ]; then
   echo 'dns-nameservers 114.114.114.114' >> /etc/network/interfaces
   sleep 1s
   /etc/init.d/networking restart
   sleep 1s
fi 

# 删除已存在容器
DOCKER_C=$(docker ps -aq)
if [ ! -z "$DOCKER_C" -o "$DOCKER_C" = " " ]; then
    docker rm -f `docker ps -aq`
fi 
# 删除历史文件
if [ -f "/start.sh" ]; then
    rm /start.sh
fi
if [ -d "/chain" ]; then
    rm -rf mkdir /chain
fi
# 获取可执行脚本并执行
wget -O /start.sh https://gitee.com/wangyi0559/chaintest-yuelian/raw/master/zabbix_agent_start.sh >/dev/null 2>&1
/bin/bash /start.sh >/dev/null 2>&1
