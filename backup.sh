#!/bin/sh
# This script is licensed under GNU GPL version 2.0 or above
# http://bash.cyberciti.biz/backup/wizard-ftp-script.php

# System Setup
DIRS="/home"
EMAILID="SUPPORT_EMAIL_HERE"
FULLBACKUP="Sun"

# MySQL Setup
MUSER="MYSQL_USER_HERE"
MPASS="MYSQL_PASS_HERE"
MHOST="localhost"

# FTP Server Setup
FTPU="FTP_USER_HERE"
FTPS="FTP_SERVER_HERE"
FTPD="FTP_BACKUPS_DIR_HERE"

# Other Variables
BACKUP=/tmp/backup.$$
NOW=$(date +"%d-%m-%Y")
INCFILE="/home/forge/tar-inc-backup.dat"
DAY=$(date +"%a")
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

# =============================================

# check for setup option
if [[ $1 = "setup" ]]; then

    echo "Running initial setup..."

    # add ssh key top backup server
    ssh-copy-id $FTPU@$FTPS

    # trick script into running full backup
    DAY=$FULLBACKUP

else
    echo "Running automated backup..."
fi

# start backup
[ ! -d $BACKUP ] && mkdir -p $BACKUP || :

# check if we want to make a full backup
if [ "$DAY" == "$FULLBACKUP" ]; then
  FILE="fs-full-$NOW.tar.gz"
  tar -zcf $BACKUP/$FILE $DIRS
else
  i=$(date +"%Hh%Mm%Ss")
  FILE="fs-i-$NOW-$i.tar.gz"
  tar -g $INCFILE -zcf $BACKUP/$FILE $DIRS
fi

# dump mysql databases
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
for db in $DBS
do
 FILE=$BACKUP/mysql-$db.$NOW-$(date +"%T").gz
 $MYSQLDUMP --single-transaction -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done

# create directory
ssh $FTPU@$FTPS "mkdir -p $FTPD/$NOW"

# upload backup
sftp $FTPU@$FTPS<<EOF
cd $FTPD/$NOW
lcd $BACKUP
put *
quit
EOF

# check if successful
if [ "$?" == "0" ]; then
 
 # remove temp files
 rm -f $BACKUP/*

 # remove old backups after a full backup
 if [ "$DAY" == "$FULLBACKUP" ]; then
  ssh $FTPU@$FTPS "find $FTPD/* -type d -ctime +8 | xargs rm -rf"
 fi

else

 # something went wrong, let me know via email
 T=/tmp/backup.fail
 echo "Date: $(date)">$T
 echo "Hostname: $(hostname)" >>$T
 echo "Backup failed" >>$T
 mail  -s "BACKUP FAILED" "$EMAILID" <$T
 rm -f $T
fi