#!/bin/sh
#
# CentOS 6 cleaner and installer
# By karljohnson.it@gmail.com
# 
# v1.35

### Global variables ###

SSHKEY=""
URL="http://build.aerisnetwork.com"
BUILDLOG="/tmp/build.log"
EMAILS="kjohnson@aerisnetwork.com" ## Separate each email with space


### IP ###

if [ -f /etc/sysconfig/network-scripts/ifcfg-venet0 ];
	then
    	IP=`/sbin/ifconfig venet0:0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
elif [ -f /etc/sysconfig/network-scripts/ifcfg-eth0 ];
	then
    	IP=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
else
		IP="127.0.0.1"
fi

################################################################################################
#####################################  Next/Go function ########################################

function enter () {
	echo ""
	read -sn 1 -p "Press any key to continue..."
}

################################################################################################
##################################### Progress function ########################################

### Progress code from haikieu @ Github ###

function delay () {
    sleep 0.2;
}

CURRENT_PROGRESS=0
function progress () {
    PARAM_PROGRESS=$1;
    PARAM_PHASE=$2;

    if [ $CURRENT_PROGRESS -le 0 -a $PARAM_PROGRESS -ge 0 ]  ; then echo -ne "[..........................] (0%)  $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 5 -a $PARAM_PROGRESS -ge 5 ]  ; then echo -ne "[#.........................] (5%)  $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 10 -a $PARAM_PROGRESS -ge 10 ]; then echo -ne "[##........................] (10%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 15 -a $PARAM_PROGRESS -ge 15 ]; then echo -ne "[###.......................] (15%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 20 -a $PARAM_PROGRESS -ge 20 ]; then echo -ne "[####......................] (20%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 25 -a $PARAM_PROGRESS -ge 25 ]; then echo -ne "[#####.....................] (25%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 30 -a $PARAM_PROGRESS -ge 30 ]; then echo -ne "[######....................] (30%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 35 -a $PARAM_PROGRESS -ge 35 ]; then echo -ne "[#######...................] (35%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 40 -a $PARAM_PROGRESS -ge 40 ]; then echo -ne "[########..................] (40%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 45 -a $PARAM_PROGRESS -ge 45 ]; then echo -ne "[#########.................] (45%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 50 -a $PARAM_PROGRESS -ge 50 ]; then echo -ne "[##########................] (50%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 55 -a $PARAM_PROGRESS -ge 55 ]; then echo -ne "[###########...............] (55%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 60 -a $PARAM_PROGRESS -ge 60 ]; then echo -ne "[############..............] (60%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 65 -a $PARAM_PROGRESS -ge 65 ]; then echo -ne "[#############.............] (65%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 70 -a $PARAM_PROGRESS -ge 70 ]; then echo -ne "[###############...........] (70%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 75 -a $PARAM_PROGRESS -ge 75 ]; then echo -ne "[#################.........] (75%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 80 -a $PARAM_PROGRESS -ge 80 ]; then echo -ne "[####################......] (80%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 85 -a $PARAM_PROGRESS -ge 85 ]; then echo -ne "[#######################...] (90%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 90 -a $PARAM_PROGRESS -ge 90 ]; then echo -ne "[##########################] (95%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 99 -a $PARAM_PROGRESS -ge 99 ]; then echo -ne "[##########################] (100%) $PARAM_PHASE \r"  ; delay; fi;
    if [ $CURRENT_PROGRESS -le 100 -a $PARAM_PROGRESS -ge 100 ]; then echo -ne "$PARAM_PHASE \n\r" ; delay; fi;

    CURRENT_PROGRESS=$PARAM_PROGRESS;
}

################################################################################################
####################################### Verify deps ############################################

function verifydep () {

	echo -ne "\nChecking global dependencies before proceeding..."

	## Verify Aeris and EPEL Repos

	if [ ! -f /etc/yum.repos.d/aeris.repo ]; then
    	yum install -y $URL/repos/aeris-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
    	echo "Aeris repository installed. Are you sure cleanup script (1) has been run first?"
	fi

	if [ ! -f /etc/yum.repos.d/epel.repo ]; then
    	yum install -y $URL/repos/epel-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
    	echo "EPEL repository installed. Are you sure cleanup script (1) has been run first?"
	fi

	## Verify opt directories

	if [ ! -d /opt/src ] ;then
		mkdir /opt/src
		echo "Directory /opt/src created. Are you sure cleanup script (1) has been run first?"
	fi

	if [ ! -d /opt/scripts ] ;then
		mkdir /opt/scripts
		echo "Directory /opt/scripts created. Are you sure cleanup script (1) has been run first?"
	fi

	echo -ne " Done! Proceeding...\n"
}


################################################################################################
################################### Option 1 cPanel Startup ####################################

function cpanel {

### cPanel installation ###

pushd /root
wget -N http://layer1.cpanel.net/latest 3>&1 4>&2 >>$BUILDLOG 2>&1
echo "Installing cPanel.. this will take about 20 minutes.."
sh latest 3>&1 4>&2 >>$BUILDLOG 2>&1
chmod 777 /var/run/screen
echo -e "\n\ncPanel has been installed."

### Aliases ###

echo "
alias apachetop=\"/opt/scripts/apache-top.py -u http://127.0.0.1/whm-server-status\"
alias apachelogs=\"tail -f /usr/local/apache/logs/error_log\"
alias eximlogs=\"tail -f /var/log/exim_mainlog\"
alias htop=\"htop -C\"
" >> /etc/profile
echo "Custom alias have been installed."

### basic MySQL configuration ###

mv /etc/my.cnf /etc/my.cnf.origin
touch /var/log/mysqld-slow.log
chown mysql:root /var/log/mysqld-slow.log
chmod 664 /var/log/mysqld-slow.log
echo "[mysqld]
innodb_file_per_table = 1
default-storage-engine = MyISAM
log-error = /var/log/mysqld.log
bind-address = 127.0.0.1

query-cache-type = 1
query-cache-size = 32M
query_cache_limit = 4M
#table_cache = 1024  ### replace with table_open_cache= if MySQL 5.6
open_files_limit = 2048
max_connections = 75
thread_cache_size = 2
tmp_table_size = 32M
max_heap_table_size = 32M
key_buffer_size = 32M
innodb_buffer_pool_size = 32M
join_buffer_size = 256k
sort_buffer_size = 256k
read_buffer_size = 256k
read_rnd_buffer_size = 256k
max_allowed_packet = 64M

slow_query_log = 1
slow_query_log_file = /var/log/mysqld-slow.log
long_query_time = 15
" > /etc/my.cnf
echo "MySQL has been basically optimized."

### Other stuff ###

wget -O /opt/scripts/apache-top.py $URL/scripts/apache-top.py 3>&1 4>&2 >>$BUILDLOG 2>&1
chmod +x /opt/scripts/apache-top.py
echo "Downloading useful scripts..."
touch /var/cpanel/optimizefsdisable
echo "Disabling cPanel optimizefs script while noatime activated."
rm -f /root/latest /root/installer.lock /root/php.ini.new /root/php.ini.orig

echo -e "\n*****************************************************************\n"
echo -e "cPanel is now installed. You can browse the following link"
echo -e "http://$IP:/whm"
echo -e "Please check /etc/my.cnf before doing /scripts/restartsrv_mysql ; tailf /var/log/mysqld.log"
echo -e "It's also important to recompile Apache/PHP. Use /scripts/easyapache"
echo -e "\n*****************************************************************\n"

}


################################################################################################
################################### Option 3 LEMP Startup ######################################

function lemp {

WWWPASS=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
SQLPASS=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
MONITPASS=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
PMA=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
MariaDB=false

### Domain configuration ###

echo -e "\n*****************************************************************"
echo -e "Nginx stack installation"
echo -e "What is the main domain? Important, it will be used to setup Web/PMA/Monit/Staging\n"
read -p "Enter the domain : " -e DOMAIN
echo -e "\nChoose PHP version between 53|54|55|56 (56 is default)"
read -p "Enter PHP version: " -e PHPVERSION

if [ "$PHPVERSION" != "53" ] && [ "$PHPVERSION" != "54" ] && [ "$PHPVERSION" != "55" ] && [ "$PHPVERSION" != "56" ]; then
	PHPVERSION="56"
fi

read -p "Do you want to switch MySQL 5.6 for MariaDB 10? (N/y): " -e MariaDB_INPUT
if [ "$MariaDB_INPUT" == "y" ] || [ "$MariaDB_INPUT" == "Y" ]; then
	MariaDB=true
fi

echo -e "\nProceeding with domain $DOMAIN and PHP $PHPVERSION...\n"

### Required directories ###

progress 0 "Basic setup for $DOMAIN..                           "

mkdir -p /home/www/$DOMAIN
mkdir /home/www/$DOMAIN/public_html
mkdir /home/www/$DOMAIN/subdomains
mkdir /home/www/$DOMAIN/subdomains/staging
mkdir /home/www/$DOMAIN/subdomains/monit

### PHP version ###

progress 5 "Installing all PHP$PHPVERSION modules...            "

if [ $PHPVERSION == "53" ]; then
	yum install -y $URL/repos/ius-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y yum-plugin-replace 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum --enablerepo ius-archive install -y php53u php53u-cli php53u-common php53u-devel php53u-enchant php53u-gd php53u-imap php53u-ioncube-loader php53u-mbstring php53u-mcrypt php53u-mysql php53u-pdo php53u-pear php53u-pecl-memcache php53u-pecl-memcached php53u-soap php53u-tidy php53u-xml php53u-xmlrpc 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "54" ]; then
	yum install -y $URL/repos/ius-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y yum-plugin-replace 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y php54 php54-cli php54-common php54-devel php54-enchant php54-gd php54-imap php54-ioncube-loader php54-mbstring php54-mcrypt php54-mysql php54-pdo php54-pear php54-pecl-memcache php54-pecl-memcached php54-soap php54-tidy php54-xml php54-xmlrpc 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "55" ]; then
	yum install -y $URL/repos/ius-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y yum-plugin-replace 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y php55u php55u-cli php55u-common php55u-devel php55u-enchant php55u-gd php55u-imap php55u-ioncube-loader php55u-opcache php55u-mbstring php55u-mcrypt php55u-mysql php55u-pdo php55u-pear php55u-pecl-memcache php55u-pecl-memcached php55u-soap php55u-tidy php55u-xml php55u-xmlrpc 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "56" ]; then
	yum install -y $URL/repos/ius-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y yum-plugin-replace 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y php56u php56u-cli php56u-common php56u-devel php56u-enchant php56u-gd php56u-imap php56u-ioncube-loader php56u-opcache php56u-mbstring php56u-mcrypt php56u-mysql php56u-pdo php56u-pear php56u-pecl-memcache php56u-pecl-memcached php56u-soap php56u-tidy php56u-xml php56u-xmlrpc 3>&1 4>&2 >>$BUILDLOG 2>&1
fi

### MariaDB 10 or MySQL 5.6 ###

if [[ "$MariaDB" == true ]]; then
	echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.0/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" > /etc/yum.repos.d/MariaDB.repo
	progress 20 "Installing MariaDB 10...                            "
	yum install -y MariaDB-server MariaDB-client 3>&1 4>&2 >>$BUILDLOG 2>&1
else
	progress 20 "Installing MySQL 5.6...                             "
	yum install -y mysql 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum replace -y mysql --replace-with mysql56u 3>&1 4>&2 >>$BUILDLOG 2>&1
	yum install -y mysql56u-server 3>&1 4>&2 >>$BUILDLOG 2>&1
fi

### Nginx-more and PHP-FPM ###

progress 35 "Installing Nginx-more and PHP-FPM...                "

yum install -y nginx-more httpd-devel 3>&1 4>&2 >>$BUILDLOG 2>&1

if [ $PHPVERSION == "53" ]; then
	yum --enablerepo ius-archive install -y php53u-fpm 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "54" ]; then
	yum install -y php54-fpm 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "55" ]; then
	yum install -y php55u-fpm 3>&1 4>&2 >>$BUILDLOG 2>&1
elif [ $PHPVERSION == "56" ]; then
	yum install -y php56u-fpm 3>&1 4>&2 >>$BUILDLOG 2>&1
fi

### Web user ###

progress 45 "Adding Web user...                                   "

adduser www 3>&1 4>&2 >>$BUILDLOG 2>&1
echo $WWWPASS | passwd www --stdin 3>&1 4>&2 >>$BUILDLOG 2>&1
chown -R www:www /home/www
chmod 755 /home/www

### Required packages ###

progress 50 "Installing Monit, VsFTPd, Memcached...              "

yum install -y db4-utils monit vsftpd memcached 3>&1 4>&2 >>$BUILDLOG 2>&1

### Optimizing services configurations ###

progress 60 "Configuring and optimizing services...               "

### Nginx ###

wget -O /etc/nginx/conf.d/vhosts/$DOMAIN.conf $URL/config/lemp-nginx-c6.conf 3>&1 4>&2 >>$BUILDLOG 2>&1
sed -i "s/replace.me/$DOMAIN/g" /etc/nginx/conf.d/vhosts/$DOMAIN.conf
echo "<?php echo 'Current PHP version: ' . phpversion(); ?>" > /home/www/$DOMAIN/public_html/index.php
if [ "$PHPVERSION" -ge "55" ]; then
	wget -O /usr/share/nginx/html/opcache.php https://raw.githubusercontent.com/amnuts/opcache-gui/master/index.php 3>&1 4>&2 >>$BUILDLOG 2>&1
fi
wget -O /usr/share/nginx/html/ioncubetest.php $URL/files/ioncubetest.php 3>&1 4>&2 >>$BUILDLOG 2>&1 ### provided by Andrew Collington @ Github

### PHP-FPM

sed -i "s/user\ \=\ apache/user\ \=\ www/g" /etc/php-fpm.d/www.conf
sed -i "s/group\ \=\ apache/group\ \=\ www/g" /etc/php-fpm.d/www.conf
sed -i "s/user\ \=\ php\-fpm/user\ \=\ www/g" /etc/php-fpm.d/www.conf
sed -i "s/group\ \=\ php\-fpm/group\ \=\ www/g" /etc/php-fpm.d/www.conf
sed -i "s/\;ping\./ping\./g" /etc/php-fpm.d/www.conf
sed -i "s/\;pm.status/pm.status/g" /etc/php-fpm.d/www.conf
sed -i "s/\;date.timezone\ \=/date.timezone\ \= America\/Montreal/g" /etc/php.ini
chown www:root /var/log/php-fpm

### Memcached ###

sed -i "s/session.save_handler\ \=\ files/session.save_handler\ \=\ memcached/g" /etc/php.ini
sed -i "/session.save_handler\ \=\ memcached/a session.save_path\ =\ \"127.0.0.1\:11211\"" /etc/php.ini
sed -i "s/session.save_path\ \=\ \"\/var\/lib\/php\/session\"/\;session.save_path\ \=\ \"\/var\/lib\/php\/session\"/g" /etc/php.ini
sed -i "s/\=\ files/\=\ memcached/g" /etc/php-fpm.d/www.conf
sed -i "s/\=\ \/var\/lib\/php\-fpm\/session/\=\ \"127.0.0.1\:11211\"/g" /etc/php-fpm.d/www.conf
sed -i "s/\=\ \/var\/lib\/php\/session/\=\ \"127.0.0.1\:11211\"/g" /etc/php-fpm.d/www.conf
sed -i "s/CACHESIZE\=\"64\"/CACHESIZE\=\"128\"/g" /etc/sysconfig/memcached
sed -i "s/OPTIONS\=\"\"/OPTIONS\=\"-l\ 127.0.0.1\"/g" /etc/sysconfig/memcached

### Allow Aeris IPs for nginx restrictions ###

sed -i "s/\#include\ conf.d\/custom\/aerisnetwork\-ips/include\ conf.d\/custom\/aerisnetwork\-ips/g" /etc/nginx/conf.d/custom/admin-ips.conf 

### Monit ###

echo "monit" > /usr/share/nginx/html/monit.html
sed -i "s/use\ address\ localhost/\#use\ address\ localhost/g" /etc/monitrc
sed -i "s/allow\ monit\:monit/allow\ monit\:$MONITPASS/g" /etc/monitrc
wget -O /etc/monit.d/services $URL/config/lemp-monit-c6 3>&1 4>&2 >>$BUILDLOG 2>&1
if [[ "$MariaDB" == true ]]; then
	sed -i "s/init.d\/mysqld/init.d\/mysql/g" /etc/monit.d/services
	sed -i "s/\/var\/run\/mysqld\/mysqld.pid/\/var\/lib\/mysql\/`hostname`.pid/g" /etc/monit.d/services
fi

### PMA ###

wget -O /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.4.13.1/phpMyAdmin-4.4.13.1-english.tar.gz 3>&1 4>&2 >>$BUILDLOG 2>&1
tar -zxf /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz -C /home/www/$DOMAIN/subdomains 3>&1 4>&2 >>$BUILDLOG 2>&1
rm -f /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz
mv /home/www/$DOMAIN/subdomains/phpMyAdmin* /home/www/$DOMAIN/subdomains/pma
echo "<?php
\$cfg['blowfish_secret'] = '$PMA';
\$cfg['Servers'][1]['auth_type'] = 'cookie';
\$cfg['Servers'][1]['host'] = 'localhost';
\$cfg['Servers'][1]['connect_type'] = 'tcp';
\$cfg['Servers'][1]['compress'] = false;
\$cfg['Servers'][1]['AllowNoPassword'] = false;
?>" > /home/www/$DOMAIN/subdomains/pma/config.inc.php
rm -rf /home/www/$DOMAIN/subdomains/pma/setup

### VsFTPd ###

sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd/vsftpd.conf 
sed -i "s/\#chroot_local_user=YES/chroot_local_user=YES/g" /etc/vsftpd/vsftpd.conf 
sed -i "s/pam_service_name=vsftpd/\#pam_service_name=vsftpd/g" /etc/vsftpd/vsftpd.conf
echo "pam_service_name=vsftpd-virtual
virtual_use_local_privs=YES
hide_ids=YES
user_config_dir=/etc/vsftpd/vusers
guest_enable=YES
" >> /etc/vsftpd/vsftpd.conf
echo "auth required pam_userdb.so db=/etc/vsftpd/virtual-users
account required pam_userdb.so db=/etc/vsftpd/virtual-users
session required pam_loginuid.so
" >> /etc/pam.d/vsftpd-virtual
echo "www" > /etc/vsftpd/vuserslist
echo "$WWWPASS" >> /etc/vsftpd/vuserslist
db_load -T -t hash -f /etc/vsftpd/vuserslist /etc/vsftpd/virtual-users.db
mkdir /etc/vsftpd/vusers/
echo "local_root=/home/www
dirlist_enable=YES
download_enable=YES
write_enable=YES
guest_username=www
" >> /etc/vsftpd/vusers/www

### SQL server ###

progress 70 "Starting SQL server and configuring...              "

if [[ "$MariaDB" == true ]]; then
	/etc/init.d/mysql start 3>&1 4>&2 >>$BUILDLOG 2>&1
else
	/etc/init.d/mysqld start 3>&1 4>&2 >>$BUILDLOG 2>&1
fi
sleep 3
/usr/bin/mysqladmin -u root password $SQLPASS 3>&1 4>&2 >>$BUILDLOG 2>&1
/usr/bin/mysqladmin -u root -p$SQLPASS -f drop test 3>&1 4>&2 >>$BUILDLOG 2>&1
echo "
[client]
user=root
password=$SQLPASS
">/root/.my.cnf
cp /root/.my.cnf /home/www/.my.cnf
chown www:www /home/www/.my.cnf
mysql -e "GRANT ALL ON *.* TO root@'127.0.0.1' IDENTIFIED BY '$SQLPASS';"
mysql -e "FLUSH PRIVILEGES;"

### Final and Startups ###

progress 85 "Starting all services...                            "

chown www:www /var/lib/php/session
chown -R www:www /home/www
echo "chown www:www /var/lib/php/session" >> /etc/rc.local
chkconfig --level 123456 httpd off >/dev/null 2>&1
chkconfig --level 345 nginx on >/dev/null 2>&1
chkconfig --level 345 memcached on >/dev/null 2>&1
chkconfig --level 345 mysqld on >/dev/null 2>&1
chkconfig --level 345 mysql on >/dev/null 2>&1
chkconfig --level 345 vsftpd on >/dev/null 2>&1
chkconfig --level 345 php-fpm on >/dev/null 2>&1
chkconfig --level 345 monit on >/dev/null 2>&1
service httpd stop 3>&1 4>&2 >>$BUILDLOG 2>&1
service memcached start 3>&1 4>&2 >>$BUILDLOG 2>&1
service nginx start 3>&1 4>&2 >>$BUILDLOG 2>&1
service vsftpd start 3>&1 4>&2 >>$BUILDLOG 2>&1
service php-fpm restart 3>&1 4>&2 >>$BUILDLOG 2>&1
service monit start 3>&1 4>&2 >>$BUILDLOG 2>&1

progress 99 "LEMP stack ready!                                   "

echo ""
echo -e "\n*****************************************************************"
echo -e "\nPlease copy all this information carefully before continuing:\n"
echo -e "SSH: root / youshouldknow!"
echo -e "User: www / $WWWPASS"
echo -e "FTP: www / $WWWPASS"
echo -e "MySQL: root / $SQLPASS"
echo -e "Web: http://www.$DOMAIN"
echo -e "Pma: http://pma.$DOMAIN / root / $SQLPASS"
echo -e "Monit: http://monit.$DOMAIN / monit / $MONITPASS"
echo -e "PageSpeed: http://www.$DOMAIN/pagespeed_global_admin/"
if [ "$PHPVERSION" -ge "55" ]; then
	echo -e "OPcache GUI: http://web.$DOMAIN/opcache.php"
fi
echo -e "IonCube test: http://web.$DOMAIN/ioncubetest.php"

echo -e "\nVersions:\n"
nginx -v
echo ""
php -v
echo ""
mysql -V
echo -e "\n*****************************************************************\n"

}


################################################################################################
############################### Option 6 FreePBX Startup #######################################

function freepbx {

echo -e "\n*****************************************************************"
echo -e "FreePBX preparation starting"
echo -e "*****************************************************************\n"

read -p "Which Panel admin password do you want ? : " -e PANEL_PASS
read -p "Which MySQL root password do you want ? : " -e MYSQL_PASS
ARI=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`

sed -i "s/enabled=1/enabled=0/g" /etc/yum.repos.d/epel.repo >/dev/null 2>&1
yum clean all -q
echo -e "\nEPEL repo disabled because it has an old asterisk version. Yum cleaned."

wget --quiet -N -O /opt/src/freepbx-2.11.0.25.tgz http://mirror.freepbx.org/freepbx-2.11.0.25.tgz
pushd /opt/src >/dev/null 2>&1
tar -zxf freepbx*.tgz
rm -f freepbx*.tgz
echo "FreePBX 2.11 downloaded and uncompressed."

yum install -q -y httpd httpd-devel php php-devel php-process php-common php-pear php-pear-DB php-mysql php-xml php-xmlrpc php-mbstring php-pdo php-cli php-mysql php-gd php-xml php-imap mysql mysql-server libxml2-devel sqlite-devel openssl-devel perl curl sox bison audiofile-devel ncurses-devel dnsmasq >/dev/null 2>&1
service mysqld restart >/dev/null 2>&1
sleep 2
echo "FreePBX dependencies such as Apache/PHP/MySQL are installed."

yum install -y -q http://packages.asterisk.org/centos/6/current/x86_64/RPMS/asterisknow-version-3.0.1-2_centos6.noarch.rpm
echo "Asterisk 11 repo installed."

/usr/bin/mysqladmin -u root password $MYSQL_PASS
/usr/bin/mysqladmin -u root -p$MYSQL_PASS create asterisk
/usr/bin/mysqladmin -u root -p$MYSQL_PASS create asteriskcdrdb
echo "MySQl root set to $MYSQL_PASS. Asterisk DBs are created. (asterisk and asteriskcdrdb)"


echo -e "\n*****************************************************************"
echo -e "Web server and Asterisk installation starting"
echo -e "\n*****************************************************************"


yum install -y -q asterisk asterisk-configs asterisk-addons asterisk-ogg asterisk-addons-mysql asterisk-voicemail asterisk-sounds-moh-opsound-wav asterisk-sounds-moh-opsound-ulaw asterisk-sounds-moh-opsound-g722 asterisk-sounds-core-en-ulaw asterisk-sounds-core-en-g722 asterisk-sounds-core-fr-ulaw asterisk-sounds-core-fr-g722 asterisk-sounds-core-fr-gsm asterisk-sounds-extra-en-ulaw asterisk-sounds-extra-en-gsm php-pear-DB --enablerepo=asterisk-11
echo "Asterisk 11 packages have been installed."

touch /var/log/asterisk/freepbx.log
chown asterisk:root /var/log/asterisk/freepbx.log
chmod 664 /var/log/asterisk/freepbx.log
sed -i "s/TTY=9/#TTY=9/g" /usr/sbin/safe_asterisk
sed -i "s/post_max_size\ =\ 8M/post_max_size\ =\ 64M/g" /etc/php.ini
sed -i "s/upload_max_filesize\ =\ 2M/upload_max_filesize\ =\ 64M/g" /etc/php.ini
sed -i "s/User apache/User asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/Group apache/Group asterisk/" /etc/httpd/conf/httpd.conf
sed -i "s/AllowOverride None/AllowOverride All/" /etc/httpd/conf/httpd.conf
chgrp asterisk /var/lib/php/session
htpasswd -b -c /var/www/.panel_htpasswd admin $PANEL_PASS
echo "
<Location />
AuthType Basic
AuthName \"FreePBX - ACCESS DENIED\"
AuthUserFile /var/www/.panel_htpasswd
<Limit GET POST>
    require valid-user
</Limit>
</Location>
" >> /etc/httpd/conf/httpd.conf
service httpd restart >/dev/null 2>&1
pushd /opt/src/freepbx* >/dev/null 2>&1
echo "Few changes done to Apache/PHP and safe_asterisk binary."

mysql -u root -p$MYSQL_PASS asterisk < SQL/newinstall.sql
mysql -u root -p$MYSQL_PASS asteriskcdrdb < SQL/cdr_mysql_table.sql
mysql -u root -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON asteriskcdrdb.* TO asteriskuser@localhost IDENTIFIED BY '$MYSQL_PASS';"
mysql -u root -p$MYSQL_PASS -e "GRANT ALL PRIVILEGES ON asterisk.* TO asteriskuser@localhost IDENTIFIED BY '$MYSQL_PASS';"
mysql -u root -p$MYSQL_PASS -e "flush privileges;"
echo -e "FreePBX SQL tables installed.\n\n"

chown -R asterisk:root /var/lib/asterisk
chmod 775 /var/lib/asterisk
chown -R asterisk:asterisk /var/www/html
echo -e "Starting Asterisk, you can ignore errors.\n\n"
/usr/sbin/safe_asterisk & >/dev/null 2>&1
sleep 2
echo -e "\nAsterisk started."
echo -e "\n*****************************************************************"
echo -e "FreePBX installation starting"
echo -e "*****************************************************************"
echo -e "You will need to enter those information : "
echo -e "USERNAME to connect to the 'asterisk' database: asteriskuser"
echo -e "PASSWORD to connect to the 'asterisk' database: $MYSQL_PASS"
echo -e "HOSTNAME of the 'asterisk' database: localhost"
echo -e "USERNAME to connect to the Asterisk Manager interface: admin"
echo -e "PASSWORD to connect to the Asterisk Manager interface: $PANEL_PASS"
echo -e "PATH to use for your AMP web root: /var/www/html"
echo -e "IP : $IP"
echo -e "*****************************************************************\n"
./install_amp
amportal chown >/dev/null 2>&1
sed -i "s/ari_password/$ARI/g" /etc/amportal.conf
mysql -u root -p$MYSQL_PASS asterisk -e "UPDATE freepbx_settings SET value='$PANEL_PASS' WHERE keyword='AMPMGRPASS';"
echo "FreePBX installed."

/usr/local/sbin/amportal stop >/dev/null 2>&1
sleep 2
/usr/local/sbin/amportal start >/dev/null 2>&1
echo "Asterisk restarted."

chkconfig mysqld on
chkconfig httpd on
echo '/usr/local/sbin/amportal restart'>> /etc/rc.local
echo "sed -i \"s/TTY=9/#TTY=9/g\" /usr/sbin/safe_asterisk" >> /etc/rc.local
echo "chown asterisk /var/lib/php/session" >> /etc/rc.local
chkconfig --level 123456 asterisk off
mv /etc/asterisk/confbridge.conf /etc/asterisk/confbridge.conf.origin
mv /etc/asterisk/cel.conf /etc/asterisk/cel.conf.origin
mv /etc/asterisk/cel_odbc.conf /etc/asterisk/cel_odbc.conf.origin
mv /etc/asterisk/logger.conf /etc/asterisk/logger.conf.origin
mv /etc/asterisk/features.conf /etc/asterisk/features.conf.origin
mv /etc/asterisk/sip_notify.conf /etc/asterisk/sip_notify.conf.origin
mv /etc/asterisk/sip.conf /etc/asterisk/sip.conf.origin
mv /etc/asterisk/iax.conf /etc/asterisk/iax.conf.origin
mv /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.origin
mv /etc/asterisk/ccss.conf /etc/asterisk/ccss.conf.origin
mv /etc/asterisk/chan_dahdi.conf /etc/asterisk/chan_dahdi.conf.origin
mv /etc/asterisk/udptl.conf /etc/asterisk/udptl.conf.origin
mv /etc/asterisk/http.conf /etc/asterisk/http.conf.origin
/var/lib/asterisk/bin/retrieve_conf >/dev/null 2>&1
mkdir /var/www/html/admin/modules/_cache
chown asterisk:asterisk /var/www/html/admin/modules/_cache
echo "Last asterisk/freepbx configurations done."
/usr/local/sbin/amportal restart >/dev/null 2>&1
echo "Asterisk started."


echo -e "\n*****************************************************************"
echo -e "FreePBX & Asterisk installation done!"
echo -e "*****************************************************************\n"
asterisk -V
echo -e "\nYou should now open your browser at : http://$IP/"
echo -e "Asterisk Manager interface username : admin"
echo -e "Asterisk Manager interface password : $PANEL_PASS"
echo -e "\n*****************************************************************\n"

}


################################################################################################
################################## OS Cleanup Startup ##########################################

function cleanup () {

SERVICES="iscsid iscsi smartd kudzu messagebus mcstrans cpuspeed NetworkManager NetworkManagerDispatcher acpid anacron apmd atd auditd autofs avahi-daemon bluetooth cups dhcdbd diskdump firstboot gpm haldaemon hidd ip6tables iptables irda isdn mdmonitor named netdump netfs netplugd nfs nfslock nscd ntpd pcmcia portmap portreserve psacct pcscd rdisc readahead_early readahead_later restorecond rhnsd rpcgssd rpcidmapd rpcsvcgssd saslauthd xfs xinetd winbind ypbind yum yum-updatesd"
RPMS="systemtap systemtap-runtime eject words alsa-lib python-ldap nfs-utils-lib mkbootdisk sos krb5-workstation pam_krb5 talk cyrus-sasl-plain doxygen gpm dhcdbd NetworkManager yum-updatesd libX11 GConf2 at-spi bluez-gnome bluez-utils cairo cups dogtail frysk gail glib-java gnome-keyring gnome-mount gnome-python2 gnome-python2-bonobo gnome-python2-gconf gnome-python2-gnomevfs gnome-vfs2 gtk2 libXTrap libXaw libXcursor libXevie libXext libXfixes libXfontcache libXft libXi libXinerama libXmu libXpm libXrandr libXrender libXt libXres libXtst libXxf86misc libXxf86vm libbonoboui libgcj libglade2 libgnome libgnomecanvas libgnomeui libnotify libwnck mesa-libGL notification-daemon pango paps pycairo pygtk2 pyspi redhat-lsb startup-notification xorg-x11-server-utils xorg-x11-xauth xorg-x11-xinit libXfont libXau libXdmcp xorg-x11-server-Xvfb ORBit2 firstboot-tui libbonobo pyorbit rhpl desktop-file-utils htmlview pinfo redhat-menus esound ppp wpa_supplicant rp-pppoe ypbind yp-tools oprofile pcmciautils oddjob-libs oddjob gnome-mime-data bluez-libs audiofile aspell aspell-en cpuspeed system-config-securitylevel-tui apmd dhcpv6-client portmap nfs-utils pcsc-lite ccid coolkey ifd-egate pcsc-lite-libs psacct nscd nss_ldap avahi avahi-glib ibmasm rdist conman xinetd samba* php*"

echo -e "Initializing cleaner and optimizer, see progress below. \n"

progress 0 "Initializing cleaner and optimizer...           "

progress 3 "Configuring few OS stuff...                     "

rm -f /etc/localtime >/dev/null 2>&1
unlink /etc/localtime >/dev/null 2>&1
ln -s /usr/share/zoneinfo/America/Montreal /etc/localtime >/dev/null 2>&1
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
echo "SELinux disabled for virtualization needs. Reboot to activate or switch back ENFORCING in /etc/selinux/config." 3>&1 4>&2 >>$BUILDLOG 2>&1
chmod 775 /var/run/screen
mkdir -p /opt/scripts
mkdir -p /opt/src

progress 6 "Services cleanup..                              "

for service in $SERVICES; do
	/sbin/chkconfig --level 123456 $service off >/dev/null 2>&1
done

/etc/init.d/auditd stop 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/httpd stop 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/xinetd stop 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/saslauthd stop 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/iptables stop 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/sendmail stop 3>&1 4>&2 >>$BUILDLOG 2>&1


progress 15 "Removing useless rpms, be patient...            "

yum remove -y $RPMS 3>&1 4>&2 >>$BUILDLOG 2>&1
yum remove -y *.i386 3>&1 4>&2 >>$BUILDLOG 2>&1
rm -f /root/anaconda-ks.cfg  /root/install.log  /root/install.log.syslog 3>&1 4>&2 >>$BUILDLOG 2>&1

progress 25 "Cleaning Yum cache...                           "

yum clean all 3>&1 4>&2 >>$BUILDLOG 2>&1


progress 35 "Updating packages, be patient...               "

yum -y update 3>&1 4>&2 >>$BUILDLOG 2>&1


progress 40 "Installing EPEL and Aeris repos...              "

yum install -y $URL/repos/epel-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
yum install -y $URL/repos/aeris-release-6.noarch.rpm 3>&1 4>&2 >>$BUILDLOG 2>&1
sed -i '/enabled\=1/a exclude\=nginx*,monit*' /etc/yum.repos.d/epel.repo


progress 45 "Installing useful packages...                   "

yum install -y bc bind-utils gcc gcc-c++ file git htop iftop iotop hdparm make mtr mutt nc nethogs openssh-clients pbzip2 perl pigz postfix pv rsync screen strace sysbench 3>&1 4>&2 >>$BUILDLOG 2>&1


progress 50 "Postfix setup...                                "

yum remove -y sendmail 3>&1 4>&2 >>$BUILDLOG 2>&1
/etc/init.d/postfix start 3>&1 4>&2 >>$BUILDLOG 2>&1
chkconfig postfix on


progress 55 "Configuring SSH...                              "

mkdir /root/.ssh 3>&1 4>&2 >>$BUILDLOG 2>&1
echo $SSHKEY > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
sed -i "s/\#Port\ 22/Port\ 2222/g" /etc/ssh/sshd_config
/etc/init.d/auditd stop >/dev/null 2>&1
restorecon /root/.ssh/authorized_keys
/etc/init.d/sshd restart >/dev/null 2>&1


progress 60 "Quick benchmarking...                           "

DD=`dd bs=1M count=512 \if=/dev/zero of=/root/benchtestfile conv=fdatasync|& awk '/copied/ {print $8 " "  $9}'`
rm -f /root/benchtestfile
syscpu=`sysbench --test=cpu --cpu-max-prime=20000 --max-requests=400 run|grep approx| awk '{print $4}'`


progress 70 "Running on $VIRT with IP $IP..                  "


progress 80 "Last configurations...                          "

if [ "$VIRT" == "openvz" ] || [ "$VIRT" == "xen" ] || [ "$VIRT" == "kvm" ] || [ "$VIRT" == "vmware" ]; then
	echo "vm.swappiness = 0" >> /etc/sysctl.conf
	progress 82 "MySQL backup script...                          "
	wget -O /opt/scripts/mysqltuner.pl https://raw.githubusercontent.com/major/MySQLTuner-perl/master/mysqltuner.pl 3>&1 4>&2 >>$BUILDLOG 2>&1
	chmod +x /opt/scripts/mysqltuner.pl
	progress 85 "MySQL Tunner script...                          "
	wget -O /opt/scripts/backup-mysql.sh $URL/scripts/backup-mysql.sh 3>&1 4>&2 >>$BUILDLOG 2>&1
	chmod +x /opt/scripts/backup-mysql.sh
fi

if [ "$VIRT" == "xen" ] || [ "$VIRT" == "kvm" ] || [ "$VIRT" == "vmware" ]; then
	echo "/usr/sbin/ntpdate -b ca.pool.ntp.org" >> /etc/rc.local
	echo "/sbin/ethtool --offload eth0 gso off tso off tx off sg off gro off" >> /etc/rc.local
fi

if [ "$VIRT" == "node" ]; then
	echo "vm.swappiness = 1" >> /etc/sysctl.conf
	progress 82 "Installing node packages...                     "
	yum install -y kpartx ebtables lm_sensors ipmitool 3>&1 4>&2 >>$BUILDLOG 2>&1
	progress 85 "Switch SSH port to 25000...                     "
	sed -i "s/\Port\ 2222/Port\ 25000/g" /etc/ssh/sshd_config
	/etc/init.d/sshd restart 3>&1 4>&2 >>$BUILDLOG 2>&1
	echo "/usr/sbin/ntpdate -b ca.pool.ntp.org" >> /etc/rc.local
	echo "/sbin/ethtool --offload eth0 gso off tso off tx off sg off gro off" >> /etc/rc.local
fi

if [ "$VIRT" == "unknown" ]; then
	echo "vm.swappiness = 0" >> /etc/sysctl.conf
	echo "/usr/sbin/ntpdate -b ca.pool.ntp.org" >> /etc/rc.local
fi

progress 99 "CentOS has been cleaned up and optimized!       "

echo ""
echo -e "\nFinal notes:\n"
if [ "$VIRT" == "openvz" ] || [ "$VIRT" == "unknown" ]; then
	echo "Nothing more to do on an $VIRT server."
fi
if [ "$VIRT" == "xen" ] || [ "$VIRT" == "kvm" ] || [ "$VIRT" == "vmware" ]; then
	echo -e "You should consider adding the following parameters to grub/fstab: elevator=noop / nohz=off / noatime"
fi
if [ "$VIRT" == "node" ]; then
	echo -e "Since this server is a node, you should consider adding the following parameters to grub/fstab: elevator=deadline / nohz=off / noatime."
	echo -e "You should also consider adding the drive/raid optmization (blockdev) in rc.local."
	echo -e "If the node has a LSI controller, install megaraid-utils package."
	echo -e "If the node is a Xen dom0, add bridge ethtool settings to /etc/rc.local."
fi
echo -e "\nBenchmark results:\n"
echo -e "Writing speed on / partition is: $DD"
echo -e "Average CPU time per-request with 400 request at 20000 max prime : $syscpu\n"
}


################################################################################################
######################################## Notify ################################################

function notify {
	rm -f /root/centos6.sh
	if [ -f /usr/bin/mutt ]; then
		echo -e "A new server has been configured. Here's the debug log attached." | mutt -a "$BUILDLOG" -s "New server builded: `hostname`" -- $EMAILS
		echo -e "\nAn email of the build has been sent. Please mannualy clear history with history -c\n"
		rm -f $BUILDLOG
		rm -f /root/sent
	else
		echo -e "\nMutt isn't installed so we cannot send a report email. Please see $BUILDLOG\nPlease mannualy clear history with history -c\n"
	fi
	cat /dev/null > /root/.bash_history
}


################################################################################################
#################################### Script Startup ############################################

clear
echo -e "\n*****************************************************************"
echo -e "CentOS 6 64bits post-installer by karljohnson.it@gmail.com"
echo -e "for NEW installation only, hit ctrl-c to cancel."
echo -e "*****************************************************************\n"

progress 0 "Detecting virtualization and IP...            "
yum install -y virt-what 3>&1 4>&2 >>$BUILDLOG 2>&1
progress 90 "Detecting virtualization and IP...            "
VIRT=`virt-what |head -n1`

progress 100 "                                               "

read -p "Script has detected that we are running '$VIRT' virtualization on IP $IP. Is that correct? (Y/n) " -e VIRT_INPUT

case "$VIRT_INPUT" in
        n)
		read -p "Enter the right virtualization (openvz|xen|kvm|vmware|node|other): " -e VIRT;
		read -p "Enter the right IP: " -e IP;
		;;
		*)
        ;;
esac

if [ "$VIRT" != "xen" ] && [ "$VIRT" != "openvz" ] && [ "$VIRT" != "kvm" ] && [ "$VIRT" != "vmware" ]; then
	VIRT="unknown"
fi

if [[ `cat /etc/redhat-release | awk '{print$1,$3}' | rev | cut -c 3- | rev` == "CentOS 6" ]] && [[ `uname -p` == "x86_64" ]]; then

	selection=
	until [ "$selection" = "0" ]; do
		clear
		echo -e "\n*************** CentOS 6 Post-Installation ***************\n"
		echo -e "Server: `hostname`"
		echo -e "IP: $IP"
		echo -e "Virtualization: $VIRT\n"
		echo -e "[1] Clean and optimize the OS"
		echo -e "[2] Proceed with cPanel"
		echo -e "[3] Proceed with LEMP and PHP 53/54/55/56"
		echo -e "[4] Proceed with "
		echo -e "[5] Proceed with Zimbra"
		echo -e "[6] Proceed with FreePBX\n"
		echo -e "[0] Quit post-installer"
		echo -e "\n**********************************************************\n"
	    echo -n "Enter selection: "
	    read selection
	    echo ""
	    case $selection in
			1 ) cleanup;enter ;;
			2 ) verifydep;cpanel;enter ;;
		    3 ) verifydep;lemp;enter ;;
			6 ) verifydep;freepbx;enter ;;
			0 ) notify;exit ;;
		    * ) echo "Please enter 1, 2, 3, 4, 5, 6 or 0"
	    esac
	done

else
	echo -e "\nNot on CentOS 6 64bits, please redeploy -.- \n"
fi