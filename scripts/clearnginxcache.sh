#!/bin/bash
#
# Simple Nginx clear cache
#
# by Karl Johnson
# kjohnson@aerisnetwork.com
#
# Version 1.0
#

CDIR1="/opt/nginx/cache"
CDIR2="/opt/nginx/proxy_temp"

if [ ! -d $CDIR1 ] || [ ! -d $CDIR2 ] ;then
        echo -e "\nError: Directory /opt/nginx/cache or /opt/nginx/proxy_temp doesn't seem to exist. Update the directories in the script.\n"
        exit 0
fi

echo -e "Current cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"
find /opt/nginx/cache -type f -exec rm {} \;
find /opt/nginx/proxy_temp -type f -exec rm {} \;
echo -e "New cache size is: $(du -hs $CDIR1 | awk '{print $1}') and $(du -hs $CDIR2 | awk '{print $1}')"
