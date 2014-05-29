#!/bin/bash
#
# Simple Nginx clear cache
#
# by Karl Johnson
# kjohnson@aerisnetwork.com
#
# Version 1.0
#

NDIR1="/opt/nginx/cache"
NDIR2="/opt/nginx/proxy_temp"
PDIR=`grep "pagespeed FileCachePath" /opt/nginx/conf/nginx.conf |awk ' { print $3; }' | sed 's/;$//'`

if [ ! -d $NDIR1 ] || [ ! -d $NDIR2 ] ;then
        echo -e "\nError: Directory /opt/nginx/cache or /opt/nginx/proxy_temp doesn't seem to exist. Update the directories in the script.\n"
        exit 0
fi

echo -e "\nCurrent Nginx cache size is: $(du -hs $NDIR1 | awk '{print $1}') and $(du -hs $NDIR2 | awk '{print $1}')"
find /opt/nginx/cache -type f -exec rm {} \;
find /opt/nginx/proxy_temp -type f -exec rm {} \;
echo -e "New Nginx cache size is: $(du -hs $NDIR1 | awk '{print $1}') and $(du -hs $NDIR2 | awk '{print $1}')\n"

if [ -z "$PDIR" ] || [ ! -d $PDIR ] ;then
	echo -e "\nPageSpeed doesn't seem to exist on this setup, skipping..\n"
else
	echo -e "Current PageSpeed cache size is: $(du -hs $PDIR | awk '{print $1}'). It will be cleared soon.\n"
	touch $PDIR/cache.flush
	chown nginx:nginx $PDIR/cache.flush
fi
