#!/bin/bash

set -euo pipefail

# prepare env
go install github.com/onsi/ginkgo/v2/ginkgo@v2.3.1

# prepare etcd env
# shellcheck disable=SC2069
etcd 2>&1 1>>etcd.log &


# Processing for master
cp ./tests/docker/my3319.cnf /data/etc/my3319.cnf
mysqld --defaults-file=/data/etc/my3319.cnf --user=work --initialize-insecure
mysqld --defaults-file=/data/etc/my3319.cnf --user=work &
sleep 3
mysql -h127.0.0.1 -P3319 -uroot -S/data/tmp/mysql3319.sock <<EOF
reset master;
GRANT REPLICATION SLAVE, REPLICATION CLIENT on *.* to 'mysqlsync'@'%' IDENTIFIED BY 'mysqlsync';
GRANT ALL ON *.* TO 'superroot'@'%' IDENTIFIED BY 'superroot' WITH GRANT OPTION;
EOF



# Processing for slaves
  
cp ./tests/docker/my3329.cnf   /data/etc/my3329.cnf
mysqld --defaults-file=/data/etc/my3329.cnf --user=work --initialize-insecure
mysqld --defaults-file=/data/etc/my3329.cnf --user=work &
sleep 3
mysql -h127.0.0.1 -P3329 -uroot -S/data/tmp/mysql3329.sock <<EOF
CHANGE MASTER TO MASTER_HOST='127.0.0.1', MASTER_PORT=3319, MASTER_USER='mysqlsync', MASTER_PASSWORD='mysqlsync', MASTER_AUTO_POSITION=1;
START SLAVE;
DO SLEEP(1);
EOF
  
cp ./tests/docker/my3339.cnf   /data/etc/my3339.cnf
mysqld --defaults-file=/data/etc/my3339.cnf --user=work --initialize-insecure
mysqld --defaults-file=/data/etc/my3339.cnf --user=work &
sleep 3
mysql -h127.0.0.1 -P3339 -uroot -S/data/tmp/mysql3339.sock <<EOF
CHANGE MASTER TO MASTER_HOST='127.0.0.1', MASTER_PORT=3319, MASTER_USER='mysqlsync', MASTER_PASSWORD='mysqlsync', MASTER_AUTO_POSITION=1;
START SLAVE;
DO SLEEP(1);
EOF

# Processing for master
cp ./tests/docker/my3379.cnf /data/etc/my3379.cnf
mysqld --defaults-file=/data/etc/my3379.cnf --user=work --initialize-insecure
mysqld --defaults-file=/data/etc/my3379.cnf --user=work &
sleep 3
mysql -h127.0.0.1 -P3379 -uroot -S/data/tmp/mysql3379.sock <<EOF
reset master;
GRANT REPLICATION SLAVE, REPLICATION CLIENT on *.* to 'mysqlsync'@'%' IDENTIFIED BY 'mysqlsync';
GRANT ALL ON *.* TO 'superroot'@'%' IDENTIFIED BY 'superroot' WITH GRANT OPTION;
EOF





