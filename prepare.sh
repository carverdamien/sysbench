#!/bin/bash
set -e -x
DBNAME=$1
DBSIZE=$2
IMAGE="${DBNAME}-${DBSIZE}"
docker run -d --name=mysql -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --net=host mysql:latest
until docker exec mysql mysql --host 127.0.0.1 -u root -e "CREATE DATABASE ${DBNAME}"; do sleep 10; done
docker run --rm --entrypoint=./sysbench/sysbench --net=host sysbench:latest --test=./sysbench/tests/db/oltp.lua --oltp-table-size=${DBSIZE} --mysql-db=${DBNAME} --mysql-host=127.0.0.1 --mysql-user=root --mysql-password= prepare
docker stop mysql
docker tag $(docker commit mysql) ${IMAGE}
docker rm -fv mysql

