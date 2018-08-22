IP_P0O1=$1
IP_P1O1=$2
IP_P2O1=$3
IP_P3O1=$4
IP_P4O1=$5
test=/home/ubuntu/chaintest-docker-script/chaintest-yuelian/wutong/test
if [ -a "$test/conf.ini" ]
then
sudo rm $test/conf.ini
else
echo "conf.ini文件不存在"
fi
sudo cp $test/conf-copy.ini $test/conf.ini
sed -i "s/IP_P0O1/$IP_P0O1/g" $test/conf.ini
sed -i "s/IP_P1O1/$IP_P1O1/g" $test/conf.ini
sed -i "s/IP_P2O1/$IP_P2O1/g" $test/conf.ini
sed -i "s/IP_P3O1/$IP_P3O1/g" $test/conf.ini
sed -i "s/IP_P4O1/$IP_P4O1/g" $test/conf.ini
sudo /bin/bash /chenxu/start-wutong.sh $6 $7 $8 $9