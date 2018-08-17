# #!/bin/sh
# #author:chenxu
# cd /home/ubuntu
# git clone -b dev.wutong https://gitee.com/czdyxs/chaintest-docker-script.git
# cd ./chaintest-docker-script
# git checkout dev.wutong
# cd  ./chaintest-yuelian/wutong/peer
# chmod +x peer
# cd -
# cd ./chaintest-yuelian/wutong/test
# chmod +x test
# cd -
# /bin/bash /home/ubuntu/chaintest-docker-script/chaintest-yuelian/wutong/wutong_start.sh 5 172.27.0.128 172.27.0.28 172.27.0.30 172.27.0.65 172.27.0.84 172.27.0.64
 
IP_P0O1=$1
IP_P1O1=$2
IP_P2O1=$3
IP_P3O1=$4
IP_P4O1=$5
test=/home/ubuntu/sdk1.2
if [ -a "$test/config/config.yaml" ]
then
sudo rm $test/conf/config.yaml
else
echo "config.yaml文件不存在"
fi
sudo cp $test/config-copy.yaml $test/conf/config.yaml  
sed -i "s/IP_P0O1/$IP_P0O1/g"$test/conf/config.yaml
sed -i "s/IP_P1O1/$IP_P1O1/g"$test/conf/config.yaml
sed -i "s/IP_P2O1/$IP_P2O1/g"$test/conf/config.yaml
sed -i "s/IP_P3O1/$IP_P3O1/g"$test/conf/config.yaml
sed -i "s/IP_P4O1/$IP_P4O1/g"$test/conf/config.yaml
kill `ps -A|grep httpservice_v1.|awk '{print $1}'`
nohup  $test/httpservice_v1 > nohup.out 2>&1