#!/bin/bash
#
# MySQL backup and optimize all databases -- Version 1.1
# Copyright 2014-2015 Karl Johnson -- karljohnson.it@gmail.com -- kj @ freenode
#
#
# You should add a daily cron for this, such as:
# 0 3 * * * /opt/scripts/backup-mysql.sh > /dev/null 2>&1
#
#

BACKUP=/backup/databases
NOW=$(date +"%Y-%m-%d")

if [ ! -f /root/.my.cnf ]; then
    echo "MySQL client config not found!"
    exit 0
fi

if [ ! -d $BACKUP ] 
then
    mkdir -p $BACKUP
fi

MUSER="root"
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

rm -f $BACKUP/*.gz

DBS="$($MYSQL --defaults-extra-file=/root/.my.cnf -u $MUSER -h $MHOST -Bse 'show databases')"
for db in $DBS
do
FILE=$BACKUP/mysql-$db.$NOW.$(date +"%H-%M-%S").gz
$MYSQLDUMP --defaults-extra-file=/root/.my.cnf -u "$MUSER" -h "$MHOST" "$db" | "$GZIP" -9 > "$FILE"
done

/usr/bin/mysqlcheck --defaults-extra-file=/root/.my.cnf -u root --auto-repair --optimize --all-databases