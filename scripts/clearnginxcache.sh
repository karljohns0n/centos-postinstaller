#!/bin/bash
#
# Simple clear cache for nginx-more
# Clear FCGI, Proxy and PageSpeed cache
#
# by Karl Johnson
# karljohnson.it@gmail.com
#
# Version 1.0
#

CDIR1="/var/lib/nginx/cache/fastcgi"
CDIR2="/var/lib/nginx/cache/fastcgi_tmp"
CDIR3=`grep "pagespeed FileCachePath" /etc/nginx/nginx.conf |awk ' { print $3; }' | sed 's/;$//'`
CDIR4="/var/lib/nginx/cache/proxy"
CDIR5="/var/lib/nginx/cache/proxy_tmp"

if [ ! -d $CDIR1 ] || [ ! -d $CDIR2 ] || [ ! -d $CDIR3 ] || [ ! -d $CDIR4 ] || [ ! -d $CDIR5 ];then
	echo -e "\nError: Directory $CDIR1 or $CDIR2 or $CDIR3 doesn't seem to exist. Update directories in the script.\n"
	exit 0
fi

echo -e "Current FCGI cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"
find $CDIR1 -type f -exec rm {} \;
find $CDIR2 -type f -exec rm {} \;
echo -e "New FCGI cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"

echo -e "Current Proxy cache size is: $(du -hs $CDIR4 | awk '{print $1}') and $(du -hs $CDIR5 | awk '{print $1}')"
find $CDIR3 -type f -exec rm {} \;
find $CDIR4 -type f -exec rm {} \;
echo -e "New Proxy cache size is: $(du -hs $CDIR4 | awk '{print $1}') and $(du -hs $CDIR5 | awk '{print $1}')"

if [ -z "$CDIR3" ] || [ ! -d $CDIR3 ] ;then
	echo -e "\nPageSpeed doesn't seem to exist on this setup, skipping..\n"
else
	echo -e "PageSpeed cache will be renewed soon. Also flushing local memcached keys..\n"
	touch $CDIR3/cache.flush
	chown nginx:nginx $CDIR3/cache.flush
	memflush --servers=localhost:11211
fi