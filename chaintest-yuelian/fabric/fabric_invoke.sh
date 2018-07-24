#!/bin/sh	
# author:wang yi
NUM1MINUTE=$*
curl -s -X GET 127.0.0.1:8080/api/invokeCC?num=$NUM1MINUTE >/dev/null 2>&1
# curl -s -X GET 127.0.0.1:8080/api/invokeCC?num=8 >/dev/null 2>&1
# sleep 1s
# curl -s -X GET 127.0.0.1:8080/api/invokeCC?num=8 >/dev/null 2>&1
# sleep 1s
# curl -s -X GET 127.0.0.1:8080/api/invokeCC?num=8 >/dev/null 2>&1
echo "success"