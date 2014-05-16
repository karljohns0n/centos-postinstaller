#!/bin/sh
#
# MySQL Backup and Optimize - All Databases
#
# by Karl Johnson
# kjohnson@aerisnetwork.com
#
# Version 1.1
#
# You should add a cron for this, exemple:
# 0 3 * * * /opt/scripts/backup-mysql.sh > /dev/null 2>&1
#
#

### System Setup ###

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

### MySQL Setup ###

MUSER="root"
MHOST="localhost"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

### Cleanup Directory ###

rm -f $BACKUP/*.gz

### Start MySQL Backup ###

DBS="$($MYSQL --defaults-extra-file=/root/.my.cnf -u $MUSER -h $MHOST -Bse 'show databases')"
for db in $DBS
do
FILE=$BACKUP/mysql-$db.$NOW.$(date +"%H-%M-%S").gz
$MYSQLDUMP --defaults-extra-file=/root/.my.cnf -u $MUSER -h $MHOST $db | $GZIP -9 > $FILE
done

### Lets optimize them at the same time ###

/usr/bin/mysqlcheck --defaults-extra-file=/root/.my.cnf -u root --auto-repair --optimize --all-databases