#!/bin/bash
#
# Simple Nginx clear cache
#
# by Karl Johnson
# kjohnson@aerisnetwork.com
#
# Version 1.0
#

CDIR1="/var/lib/nginx/cache/fastcgi"
CDIR2="/var/lib/nginx/cache/fastcgi_tmp"
CDIR3=`grep "pagespeed FileCachePath" /etc/nginx/nginx.conf |awk ' { print $3; }' | sed 's/;$//'`

if [ ! -d $CDIR1 ] || [ ! -d $CDIR2 ] || [ ! -d $CDIR3 ];then
	echo -e "\nError: Directory $CDIR1 or $CDIR2 or $CDIR3 doesn't seem to exist. Update the directories in the script.\n"
	exit 0
fi

echo -e "Current cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"
find $CDIR1 -type f -exec rm {} \;
find $CDIR2 -type f -exec rm {} \;
echo -e "New cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"

if [ -z "$CDIR3" ] || [ ! -d $CDIR3 ] ;then
	echo -e "\nPageSpeed doesn't seem to exist on this setup, skipping..\n"
else
	echo -e "Current PageSpeed cache size is: $(du -hs $CDIR3 | awk '{print $1}'). It will be cleared soon.\n"
	touch $CDIR3/cache.flush
	chown nginx:nginx $CDIR3/cache.flush
fi
