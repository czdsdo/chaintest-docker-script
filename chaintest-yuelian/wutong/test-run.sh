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
cd $test
if [ "$6" -eq "-1" ]
then
sudo nohup ./test stress -n 200 -t store   > nohup.out 2>&1 &
sleep ${9}s
kill `jobs -l |grep "./test stress"|awk '{print $2}'`
else
sudo /bin/bash /chenxu/start-wutong.sh $6 $7 $8 $9
fi