#!/bin/bash
# 进入目录 
MULU=$(pwd)/tjftt
# 编译
function buildProjrct(){
    #编译donet
    echo "build aspnet-core";
    cd $MULU/aspnet-core;
    # export http_proxy=http://10.1.4.251:8848
    # export https_proxy=http://10.1.4.251:8848
    dotnet restore -s "https://nuget.cnblogs.com/v3/index.json" -s "https://api.nuget.org/v3/index.json" "Hoopox.ChainEval.sln"; 
    dotnet publish -o publish -c Release "src/Hoopox.ChainEval.Migrator/Hoopox.ChainEval.Migrator.csproj";
    dotnet publish -o publish -c Release "src/Hoopox.ChainEval.Web.Host/Hoopox.ChainEval.Web.Host.csproj";
    # unset http_proxy
    # unset https_proxy
    #编译前端
    echo "build angular";
    cd $MULU/angular;
    rm -rf node_modules;
    sudo /usr/local/bin/npm install --registry=https://registry.npm.taobao.org ;
    sudo /usr/local/bin/npm run build:prod-aot;
}
# 生成docker镜像
function buildDocker(){
    # 关闭已有容器
    CONTAINER_ID=$(docker ps -a | grep "chainevalmigrator" | awk '{print $1}')
        if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
            echo " docker rm -f chainevalmigrator";
            docker rm -f $CONTAINER_ID  >/dev/null 2>&1;
        fi
    CONTAINER_ID=$(docker ps -a | grep "chainevalhost" | awk '{print $1}')
        if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
            echo " docker rm -f chainevalhost";
            docker rm -f $CONTAINER_ID  >/dev/null 2>&1;
        fi
    CONTAINER_ID=$(docker ps -a | grep "chainevalwebsite" | awk '{print $1}')
        if [ ! -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
            echo " docker rm -f chainevalwebsite";
            docker rm -f $CONTAINER_ID  >/dev/null 2>&1;
        fi
    # 删除旧镜像
    DOCKER_IMAGE_ID=$(docker images | grep "chainevalmigrator" | awk '{print $3}')
        if [ ! -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
            echo " docker rmi chainevalmigrator";
		    docker rmi $DOCKER_IMAGE_ID >/dev/null 2>&1;
        fi
    DOCKER_IMAGE_ID=$(docker images | grep "chainevalhost" | awk '{print $3}')
        if [ ! -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
            echo " docker rmi chainevalhost";
		    docker rmi $DOCKER_IMAGE_ID >/dev/null 2>&1;
        fi
    DOCKER_IMAGE_ID=$(docker images | grep "chainevalwebsite" | awk '{print $3}')
        if [ ! -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
            echo " docker rmi chainevalwebsite";
		    docker rmi $DOCKER_IMAGE_ID >/dev/null 2>&1;
        fi
    # 生成新镜像
    cd $MULU/aspnet-core/src/Hoopox.ChainEval.Migrator/publish/;
    echo "docker build chainevalmigrator";
    docker build -t chainevalmigrator .;
    cd $MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/publish/;
    echo "docker build chainevalhost";
    docker build -t chainevalhost .;
    cd $MULU/angular;
    echo "docker build chainevalwebsite";
    docker build -t chainevalwebsite .;
}
# 启动
function run(){
    docker run -d --name chainevalmigrator  chainevalmigrator;

    sleep 20s
    docker run -d --name chainevalhost -p 21021:21021 -e "ASPNETCORE_URLS=http://*:21021" chainevalhost;

    sleep 20s
    docker run -d --name chainevalwebsite -p 10080:80 chainevalwebsite;
}
sleep 2s;
buildProjrct;
sleep 2s;
buildDocker;
sleep 2s;
run;