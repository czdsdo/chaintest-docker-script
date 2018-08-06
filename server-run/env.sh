#!/bin/bash

# 获得当前目录
MULU=$(pwd)/tjftt
# 获得本机IP（暂不需要，由以下两项指定）
# IP=`ifconfig  | grep 'inet addr:' | grep -v '127.0.0.1' | grep -v '0.0.0.0' | grep -v '172.17.' | cut -d: -f2 | awk '{ print $1}'`
# 设置MYSQL数据库IP（这里是本机IP）
MYSQL_IP="10.1.1.8"
# 设置对外服务的公网IP（zabbix）,由实际确定（可以是本机公网IP）。
PUBLIC_IP_ZABBIX="10.1.1.8"
# 设置对外服务的公网IP（donet）,由实际确定（原则上本机公网IP）。
PUBLIC_IP_DONET="10.1.1.8"
# 本地zabbix仓库IP
REGISTRY="10.1.1.6:5000"
# 配置本地仓库，允许insecure-registries
mkdir -p /etc/docker;
if [ ! -f "/etc/docker/daemon.json" ]; then
    touch /etc/docker/daemon.json
fi
DAEMON=$(cat /etc/docker/daemon.json | grep "$REGISTRY")
if [ -z "$DAEMON" -o "$DAEMON" = " " ]; then
    echo "{\"insecure-registries\": [\"$REGISTRY\"]}" >/etc/docker/daemon.json
fi

# apt-get设置国内阿里源
function testSOURCE(){
    SOURCE=$(cat /etc/apt/sources.list | grep http://mirrors.aliyun.com/ubuntu/);
    if [ -z "$SOURCE" -o "$SOURCE" = " " ]; then
        echo "aliyun source";
        echo "# $(lsb_release -cs)
deb-src http://archive.ubuntu.com/ubuntu $(lsb_release -cs) main restricted #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) universe
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates universe
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs) multiverse
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-backports main restricted universe multiverse #Added by software-properties
deb http://archive.canonical.com/ubuntu $(lsb_release -cs) partner
deb-src http://archive.canonical.com/ubuntu $(lsb_release -cs) partner
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security main restricted multiverse universe #Added by software-properties
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security universe
deb http://mirrors.aliyun.com/ubuntu/ $(lsb_release -cs)-security multiverse" > /etc/apt/sources.list;
apt-get update >/dev/null 2>&1;
    fi
}
# 检查相关软件是否安装
function testENV(){
    #dotnet是否安装
    if hash dotnet 2>/dev/null; then
        echo "dotnet `dotnet --version` installed" ;
    else
        echo "install dotnet 2.0.2";
        curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg;
        sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg;
        sudo sh -c "echo \"deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main\" > /etc/apt/sources.list.d/dotnetdev.list";
        sudo apt-get update >/dev/null 2>&1;
        sudo apt-get install -y dotnet-sdk-2.0.2;
        sleep 1s;
        echo "dotnet `dotnet --version` installed";
    fi

    #nodejs是否安装
    if hash node 2>/dev/null; then
        echo "node `node -v` installed";
    else
        echo "install node v8.5.0";
        wget https://nodejs.org/dist/v8.5.0/node-v8.5.0-linux-x64.tar.xz;
        sleep 2s;
        tar xvJf node-v8.5.0-linux-x64.tar.xz >/dev/null 2>&1;
        rm node-v8.5.0-linux-x64.tar.xz;
        rm -rf /usr/local/nodejs;
        mv node-v8.5.0-linux-x64 /usr/local/nodejs;
        rm -rf /usr/local/bin/node;
        rm -rf /usr/local/bin/npm ;
        rm -rf /usr/local/bin/cnpm ;
        ln -s /usr/local/nodejs/bin/node /usr/local/bin;
        ln -s /usr/local/nodejs/bin/npm /usr/local/bin;
        sleep 2s;
        npm install -g cnpm --registry=https://registry.npm.taobao.org;
        ln -s /usr/local/nodejs/bin/cnpm /usr/local/bin/cnpm;
        sleep 1s;
        echo "node `node -v` installed";
    fi

    #docker是否安装
    if hash docker 2>/dev/null; then
        echo "docker `docker -v` installed";
    else
        echo "install docker 17.03";
        apt-get update >/dev/null 2>&1;
        apt-get install -y -qq \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common;
        curl -fsSL https://download.daocloud.io/docker/linux/ubuntu/gpg | apt-key add - ;
        add-apt-repository \
            "deb [arch=$(dpkg --print-architecture)] https://download.daocloud.io/docker/linux/ubuntu \
            $(lsb_release -cs) \
            stable";
        apt-get update >/dev/null 2>&1;
        apt-get install -y docker-ce=17.03.2* ;
        service docker start;
        sleep 1s;
        echo "docker `docker -v` installed";
    fi

    #docker images 是否已经下载
    DOCKER_IMAGE_ID=$(docker images | grep "nginx" | awk '{print $3}')
    if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
        echo "docker pull nginx:latest";
	    docker pull $REGISTRY/nginx:latest;
        docker tag $REGISTRY/nginx:latest nginx:latest;
        docker rmi $REGISTRY/nginx:latest;
    else
        echo "docker nginx:latest pulled";
    fi
    DOCKER_IMAGE_ID=$(docker images | grep "mysql" | awk '{print $3}')
    if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
        echo "docker pull mysql:latest";
	    docker pull $REGISTRY/mysql:5.7;
        docker tag $REGISTRY/mysql:5.7 mysql:5.7;
        docker rmi $REGISTRY/mysql:5.7;
    else
        echo "docker mysql:latest pulled";
    fi
    DOCKER_IMAGE_ID=$(docker images | grep "microsoft/aspnetcore" | awk '{print $3}')
    if [ -z "$DOCKER_IMAGE_ID" -o "$DOCKER_IMAGE_ID" = " " ]; then
        echo "docker pull microsoft/aspnetcore:latest";
	    docker pull $REGISTRY/microsoft/aspnetcore:latest;
        docker tag $REGISTRY/microsoft/aspnetcore:latest microsoft/aspnetcore:latest;
        docker rmi $REGISTRY/microsoft/aspnetcore:latest;
    else
        echo "docker microsoft/aspnetcore:latest pulled";
    fi
    #ubuntu编译环境相关软件下载
    echo "apt-get install -y -qq build-essential jq";
    #apt-get update >/dev/null 2>&1;
    apt-get install -y -qq build-essential jq;
}
# 配置MySQL,并启动
function testMYSQL(){
    #配置MySQL设置为UTF8编码
    if [ ! -d "/etc/mysql" ]; then
        mkdir /etc/mysql;
    fi
    if [ ! -f "/etc/mysql/my.cnf" ]; then
echo '[mysql]
default-character-set = utf8
[mysqld]
character-set-server = utf8
[mysqld_safe]
default-character-set = utf8
[mysql.server]
default-character-set = utf8
[client]
default-character-set = utf8' > /etc/mysql/my.cnf;
    fi
    sleep 2s;
    # 容器启动MySQL
    CONTAINER_ID=$(docker ps -a | grep "mysql" | awk '{print $1}')
        if [ -z "$CONTAINER_ID" -o "$CONTAINER_ID" = " " ]; then
            echo "start mysql";
            rm -rf /var/lib/mysql ;
            docker run -d --restart always \
            -v /var/lib/mysql:/var/lib/mysql \
            -v /etc/mysql:/etc/mysql \
            -p 3306:3306 \
            -e MYSQL_ROOT_PASSWORD=123456 \
            --name mysql mysql:5.7;
        else
            echo "mysql exists";
        fi
}
#DONET后台相关配置文件，配置内容由编写代码者提供
function testCONFIG(){
    cd $MULU
    git checkout dev.xingyuyang
    cd -
    #angular/src/assets/appconfig.json 文件配置
    mv $MULU/angular/src/assets/appconfig.json $MULU/temp.json
    sed '/^$/d' $MULU/temp.json | jq "
    .remoteServiceBaseUrl=\"http://$PUBLIC_IP_DONET:21021\"|
    .appBaseUrl=\"http://$PUBLIC_IP_ZABBIX:10080\"" >$MULU/angular/src/assets/appconfig.json
    rm $MULU/temp.json

    #aspnet-core/src/Hoopox.ChainEval.Migrator/appsettings.json 文件配置
    mv $MULU/aspnet-core/src/Hoopox.ChainEval.Migrator/appsettings.json $MULU/temp.json
    sed '/^$/d' $MULU/temp.json | jq "
    .ConnectionStrings.Default=\"Server=$MYSQL_IP;Database=ChainEvalDb;charset=utf8;User=root;Password=123456;\"
    " >$MULU/aspnet-core/src/Hoopox.ChainEval.Migrator/appsettings.json
    rm $MULU/temp.json

    #aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.json 文件配置
    mv $MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.json $MULU/temp.json
    sed '/^$/d' $MULU/temp.json | sed '/\/\/load item history/d' | jq "
    .ConnectionStrings.Default=\"Server=$MYSQL_IP;Database=ChainEvalDb;charset=utf8;User=root;Password=123456;\"|
    .App.CorsOrigins=\"http://localhost:4200/,http://$PUBLIC_IP_ZABBIX:10080\"|
    .Zabbix.ServerAddress=\"http://10.1.1.170\"|
    .CloudHostingPlatforms.Settings[1].OsIpAddress=\"10.1.3.239\"|
    .CloudHostingPlatforms.Settings[1].ZabbixServerIp=\"10.1.1.170\"|
    .CloudHostingPlatforms.Settings[1].ImageId=\"ec5f2f1f-5f27-4bd0-b068-97c2f43c2114\"
    " >$MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.json
    rm $MULU/temp.json

    #aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Production.json 文件配置
    mv $MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Production.json $MULU/temp.json
    sed '/^$/d' $MULU/temp.json | sed '/\/\/load item history/d' | jq "
    .ConnectionStrings.Default=\"Server=$MYSQL_IP;Database=ChainEvalDb;charset=utf8;User=root;Password=123456;\"|
    .App.CorsOrigins=\"http://localhost:4200/,http://$PUBLIC_IP_ZABBIX:10080\"
    " >$MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Production.json
    rm $MULU/temp.json

    #aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Production.json 文件配置
    mv $MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Staging.json $MULU/temp.json
    sed '/^$/d' $MULU/temp.json | sed '/\/\/load item history/d' | jq "
    .ConnectionStrings.Default=\"Server=$MYSQL_IP;Database=ChainEvalDb;charset=utf8;User=root;Password=123456;\"|
    .App.CorsOrigins=\"http://localhost:4200/,http://$PUBLIC_IP_ZABBIX:10080\"
    " >$MULU/aspnet-core/src/Hoopox.ChainEval.Web.Host/appsettings.Staging.json
    rm $MULU/temp.json
}
testSOURCE
sleep 2s;
testENV;
sleep 2s;
testMYSQL
sleep 2s
testCONFIG
sleep 2s
echo "success"