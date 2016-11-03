#!/bin/bash
set -e -x
DBNAME=$1
DBSIZE=$2
VOLUME="${DBNAME}-${DBSIZE}"
VPATH='/var/lib/mysql'
docker volume create --name "$VOLUME"
docker run -d --name=mysql -v "$VOLUME:$VPATH" -e MYSQL_ALLOW_EMPTY_PASSWORD=yes --net=host mysql:latest
until docker exec mysql mysql --host 127.0.0.1 -u root -e "CREATE DATABASE ${DBNAME}"; do sleep 10; done
docker run --rm --entrypoint=./sysbench/sysbench --net=host sysbench:latest --test=./sysbench/tests/db/oltp.lua --oltp-table-size=${DBSIZE} --mysql-db=${DBNAME} --mysql-host=127.0.0.1 --mysql-user=root --mysql-password= prepare
docker rm -fv mysql
