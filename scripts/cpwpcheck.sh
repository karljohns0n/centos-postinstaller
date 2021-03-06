#!/bin/bash
#
# Simple WordPress version checkup for cPanel with suPHP/CGI/ruid2/cloudlinux - not mod_php -- Version 1.1
# Also chmod 600 wp-config to secure file from other users
# Copyright 2014-2015 Karl Johnson -- karljohnson.it@gmail.com -- kj @ freenode
#
# 

LOG="/tmp/cpwpcheck.log"
EMAILS="" ## Separate with space

if [ ! -f /usr/bin/mutt ]; then
  echo "Mutt is not in /usr/bin, please check"
  exit 1
fi

rm -f $LOG

{
	echo -e "cPanel WordPress checkup starting. Trying to find every WP on this server and:\n"
	echo -e "- Find WP directory and version"
	echo -e "- Chmod wp-config.php to 600 to secure file reading"
	echo -e "\nProceeding.." 
} 3>&1 4>&2 >>$LOG 2>&1

for vhost in $(grep DocumentRoot /usr/local/apache/conf/httpd.conf|grep "public_html\|subdomains" |awk -v vcol=2 '{print $vcol}'|sort|uniq -u); do
	find "$vhost" -wholename "*wp-includes/version.php" | while read wpverfile; do
		wpdir=$(echo "$wpverfile" | sed "s/\/wp-includes\/version.php//")
		echo -e "\n\nFound WP in : $wpdir" 3>&1 4>&2 >>$LOG 2>&1
		echo -e "WP version is: $(grep "^\$wp_version" "$wpverfile" | cut -d "'" -f 2)" 3>&1 4>&2 >>$LOG 2>&1
		chmod 600 "$wpdir/wp-config.php"
		wpconfigfile=$(ls -al "$wpdir/wp-config.php" |awk '{print $1,$3,$4}')
		echo -e "Configured wp-config permissions to 600: $wpconfigfile" 3>&1 4>&2 >>$LOG 2>&1
	done
done

echo -e "Here's the log of the cPanel WordPress daily checkup for $(hostname)." | mutt -a $LOG -s "cPanel WordPress daily checkup report for: $(hostname)" -- $EMAILS

rm -f /root/sent
rm -f $LOG