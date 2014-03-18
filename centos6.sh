#!/bin/sh
#
# CentOS 6 epic Cleaner and Installer
# By kjohnson@aerisnetwork.com
# 
# v2.32 2014-03-18

OS1=`cat /etc/redhat-release | awk '{print$1}'`
OS2=`cat /etc/redhat-release | awk '{print$3}'`
arch=`uname -p`
hostname=`hostname`
URL="http://sky.aerisnetwork.net/build"


######## Option 1 cPanel Startup ########

function cpanel {

### cpanel installation ###

pushd /root
wget -N http://layer1.cpanel.net/latest -q
sh latest

### alias ###

echo "
alias apachetop=\"/opt/scripts/apache-top.py -u http://127.0.0.1/whm-server-status\"
alias apachelogs=\"tail -f /usr/local/apache/logs/error_log\"
alias eximlogs=\"tail -f /var/log/exim_mainlog\"
alias htop=\"htop -C\"
" >> /etc/profile

### basic mysql config ###

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
table_cache = 1000
open_files_limit = 2000
max_connections = 100
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

### other stuff ###

wget -q -O /opt/scripts/apache-top.py $URL/scripts/apache-top.py

rm -f /root/centos6.sh latest installer.lock


echo -e "\n*****************************************************************\n"
echo -e "cPanel is now installed. You can browse the following link"
echo -e "http://$IP:/whm"
echo -e "Please check /etc/my.cnf before doing /scripts/restartsrv_mysql ; tail -f /var/log/mysqld.log"
echo -e "\n*****************************************************************\n"

}


######## Option 3 LAMP with Nginx Startup ########

function LAMP_with_nginx {

PASS1=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
PASS2=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
PASS3=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
PMA=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`
MONIT=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`

### Domain configuration ###

## demander la version de PHP ici ##

echo -e "\n*****************************************************************"
echo -e "Webkit preparation LAMP"
echo -e "What is the main domain? Will be used to install Web/PMA/Munin/Monit/Staging\n"
read -p "Enter the domain : " -e DOMAIN
echo -e "\nProceeding with $DOMAIN\n"

mkdir /home/www/$DOMAIN
mkdir /home/www/$DOMAIN/public_html
mkdir /home/www/$DOMAIN/subdomains
mkdir /home/www/$DOMAIN/subdomains/staging
mkdir /home/www/$DOMAIN/subdomains/monit
ln -s /var/www/html/munin /home/www/$DOMAIN/subdomains/munin



echo -e "\n*****************************************************************"
echo -e "Installing packages.."
echo -e "*****************************************************************\n"

rpm -ivh $URL/repos/ius-release-1.0-11.ius.centos6.noarch.rpm
yum install -y -q yum-plugin-replace 
yum install -y -q db4-utils httpd httpd-devel monit munin munin-node mysql55 mysql55-server php53u php53u-cli php53u-common php53u-devel php53u-enchant php53u-gd php53u-imap php53u-ioncube-loader php53u-mbstring php53u-mcrypt php53u-mysql php53u-pdo php53u-pear php53u-pecl-memcached php53u-soap php53u-tidy php53u-xml php53u-xmlrpc vsftpd

echo -e "\n*****************************************************************"
echo -e "Adding web user, set password and permissions.."
echo -e "*****************************************************************\n"

adduser www
echo $PASS1 | passwd www --stdin
chown -R www:www /home/www
chmod 755 /home/www

echo -e "\n*****************************************************************"
echo -e "Optimizing services configuration.."
echo -e "*****************************************************************\n"


### Apache ###
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.origin
wget -q -O /etc/httpd/conf/httpd.conf $URL/config/httpd22-nginx-centos6.conf
sed -i "s/replaceme/$DOMAIN/g" /etc/httpd/conf/httpd.conf


### MySQL ###
/etc/init.d/mysqld restart
/usr/bin/mysqladmin -u root password $PASS2
echo "
[client]
user=root
password=$PASS2
">/root/.my.cnf
cp /root/.my.cnf /home/www/.my.cnf


### Monit ###
echo "Monit monitoring" > /var/www/html/monit.html
echo "Default" > /var/www/html/index.html
echo "<?php echo 'Current PHP version: ' . phpversion(); ?>" > /home/www/$DOMAIN/public_html/index.php

echo "set httpd port 2812 and allow monit:$MONIT" >> /etc/monit.conf
echo "check process httpd with pidfile /etc/httpd/run/httpd.pid
group apache
start program = \"/etc/init.d/httpd start\"
stop program = \"/etc/init.d/httpd stop\"
mode active
if failed host 127.0.0.1 port 81 protocol http
and request \"/monit.html\"
then restart
if 5 restarts within 5 cycles then timeout
">/etc/monit.d/apache
echo "check process mysqld with pidfile /var/run/mysqld/mysqld.pid
start program = \"/etc/init.d/mysqld start\"
stop program = \"/etc/init.d/mysqld stop\"
mode active
if failed host 127.0.0.1 port 3306 then restart
if 5 restarts within 5 cycles then timeout
">/etc/monit.d/mysqld
echo "check process nginx with pidfile /opt/nginx/logs/nginx.pid
group nginx
start program = \"/etc/init.d/nginx start\"
stop program = \"/etc/init.d/nginx stop\"
mode active
if children > 250 then restart
if loadavg(5min) greater than 10 for 8 cycles then stop
if 3 restarts within 5 cycles then timeout
">/etc/monit.d/nginx


### PMA ###
wget -O /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.9/phpMyAdmin-4.0.9-english.tar.gz?r=http%3A%2F%2Fwww.phpmyadmin.net%2Fhome_page%2Fdownloads.php&ts=1384797208&use_mirror=hivelocity"
tar -zxvf /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz -C /home/www/$DOMAIN/subdomains
rm -f /home/www/$DOMAIN/subdomains/phpmyadmin.tar.gz
mv /home/www/$DOMAIN/subdomains/phpMyAdmin* /home/www/$DOMAIN/subdomains/pma
echo "<?php
$cfg['blowfish_secret'] = '$PMA';  // use here a value of your choice
 
$i=0;
$i++;
$cfg['Servers'][$i]['auth_type']     = 'cookie';
?>" > /home/www/$DOMAIN/subdomains/pma/config.inc.php
rm -rf /home/www/$DOMAIN/subdomains/pma/setup


### Munin ###
sed -i "s/\[localhost\]/\[$DOMAIN\]/g" /etc/munin/munin.conf
pushd /etc/munin/plugins
find /etc/munin/plugins -exec unlink {} \;
ln -s /usr/share/munin/plugins/cpu /etc/munin/plugins/cpu
ln -s /usr/share/munin/plugins/df /etc/munin/plugins/df
ln -s /usr/share/munin/plugins/load /etc/munin/plugins/load
ln -s /usr/share/munin/plugins/memory /etc/munin/plugins/memory
ln -s /usr/share/munin/plugins/apache_accesses /etc/munin/plugins/apache_accesses
ln -s /usr/share/munin/plugins/apache_volume /etc/munin/plugins/apache_volume
ln -s /usr/share/munin/plugins/nginx_status /etc/munin/plugins/nginx_status
ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/nginx_request
ln -s /usr/share/munin/plugins/mysql_queries /etc/munin/plugins/mysql_queries
ln -s /usr/share/munin/plugins/mysql_threads /etc/munin/plugins/mysql_threads
ln -s /usr/share/munin/plugins/mysql_slowqueries /etc/munin/plugins/mysql_slowqueries
echo"
[apache_*]
env.url   http://127.0.0.1:%d/server-status?auto
env.ports 81
 
[mysql*]
user root
group wheel
env.mysqladmin /usr/bin/mysqladmin
env.mysqlopts --defaults-extra-file=/root/.my.cnf
" >> /etc/munin/plugin-conf.d/munin-node
pushd /root

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
echo "$PASS1" >> /etc/vsftpd/vuserslist
db_load -T -t hash -f /etc/vsftpd/vuserslist /etc/vsftpd/virtual-users.db
mkdir /etc/vsftpd/vusers/
echo "local_root=/home/www
dirlist_enable=YES
download_enable=YES
write_enable=YES
guest_username=www
" >> /etc/vsftpd/vusers/www

### Nginx ###


### Final and Startups ###
chown www:www /var/lib/php/session
chown -R www:www /home/www
echo "chown www:www /var/lib/php/session" >> /etc/rc.local
chkconfig --level 2345 mysqld on
chkconfig --level 2345 monit on
chkconfig --level 2345 munin-node on
chkconfig --level 2345 vsftpd on



echo -e "\n*****************************************************************"
echo -e "Webkit installed!\n"
echo -e "Information for Jira ticket:\n"
echo -e "h3.Configurations"
echo -e "\n*Services*\n"
echo -e "SSH: root / replace"
echo -e "Apache: www / $PASS1"
echo -e "FTP: www / $PASS1"
echo -e "MySQL: root / $PASS2"
echo -e "Monit: monit / $PASS3"
echo -e "\nVersions:\n"
httpd -v
php -v
mysql -V
echo -e "\n*****************************************************************\n"

}


######## OS Cleanup Startup ########

function cleanup {

sshkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWfE1zygFZ8tbnG2yGcgc1LFGoSkFWVvB+TGIr6l5R+z/j7CBFQlvo9Wn5ziNBIUy7esXJN0qy2i+p5ZN1v1WBLi0GQZ8ZjqyM7f58wQlxlS7UEEVITwtGNv8B33M+Akg5kRBQgmNswsshukUHLQH8xhdJKBq76DFMXrlOYgXeAF/CBWBf/o5PqdDC9Qi/BqP5tCtsPGDIX9rj3qwzksoAI98gEhGhNYU4Tu7duC/Ie6rhseQIBHdH3xky7og8TOPNWRzSy5/9v5MNYmC+AjYXXPko8mnlMOheDNYerf6S/nz0r8J0EBD5KQEWQcURUoHeHD2+NSgRScTxVW7DxsKT karl@kjmac.aerisnetwork.net-DO-NOT-REMOVE"
SERVICES="iscsid iscsi smartd kudzu messagebus mcstrans cpuspeed NetworkManager NetworkManagerDispatcher acpid anacron apmd atd auditd autofs avahi-daemon bluetooth cups dhcdbd diskdump firstboot gpm haldaemon hidd ip6tables iptables irda isdn mdmonitor named netdump netfs netplugd nfs nfslock nscd ntpd pcmcia portmap portreserve psacct pcscd rdisc readahead_early readahead_later restorecond rhnsd rpcgssd rpcidmapd rpcsvcgssd saslauthd xfs xinetd winbind ypbind yum yum-updatesd"
RPMS="systemtap systemtap-runtime eject words alsa-lib python-ldap nfs-utils-lib mkbootdisk sos krb5-workstation pam_krb5 talk cyrus-sasl-plain doxygen gpm dhcdbd NetworkManager yum-updatesd libX11 GConf2 at-spi bluez-gnome bluez-utils cairo cups dogtail frysk gail glib-java gnome-keyring gnome-mount gnome-python2 gnome-python2-bonobo gnome-python2-gconf gnome-python2-gnomevfs gnome-vfs2 gtk2 libXTrap libXaw libXcursor libXevie libXext libXfixes libXfontcache libXft libXi libXinerama libXmu libXpm libXrandr libXrender libXt libXres libXtst libXxf86misc libXxf86vm libbonoboui libgcj libglade2 libgnome libgnomecanvas libgnomeui libnotify libwnck mesa-libGL notification-daemon pango paps pycairo pygtk2 pyspi redhat-lsb startup-notification xorg-x11-server-utils xorg-x11-xauth xorg-x11-xinit libXfont libXau libXdmcp xorg-x11-server-Xvfb ORBit2 firstboot-tui libbonobo pyorbit rhpl desktop-file-utils htmlview pinfo redhat-menus esound ppp wpa_supplicant rp-pppoe ypbind yp-tools oprofile pcmciautils oddjob-libs oddjob gnome-mime-data bluez-libs audiofile aspell aspell-en cpuspeed system-config-securitylevel-tui apmd dhcpv6-client portmap nfs-utils pcsc-lite ccid coolkey ifd-egate pcsc-lite-libs psacct nscd nss_ldap avahi avahi-glib ibmasm rdist conman xinetd samba* php*"

echo -e "\n*****************************************************************"
echo -e "Configuring OS (SELinux, timezone)"
echo -e "*****************************************************************\n"

rm -f /etc/localtime >/dev/null 2>&1
unlink /etc/localtime >/dev/null 2>&1
ln -s /usr/share/zoneinfo/America/Montreal /etc/localtime >/dev/null 2>&1
echo "Timezone set to Montreal."
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config >/dev/null 2>&1
echo "SELinu disabled. Need to reboot."
cat /dev/null > /root/.bash_history ## Need a way to fix history -c
echo "History cleared."


echo -e "\n*****************************************************************"
echo -e "Disabling services and stopping default services.."
echo -e "*****************************************************************\n"

for service in $SERVICES; do
/sbin/chkconfig --level 2345 $service off >/dev/null 2>&1
done

/etc/init.d/auditd stop >/dev/null 2>&1
/etc/init.d/httpd stop >/dev/null 2>&1
/etc/init.d/xinetd stop >/dev/null 2>&1
/etc/init.d/sendmail stop >/dev/null 2>&1
/etc/init.d/postfix stop >/dev/null 2>&1 
/etc/init.d/saslauthd stop >/dev/null 2>&1
echo "All unused services have been stopped and removed from boot."

echo -e "\n*****************************************************************"
echo -e "Removing useless rpms.."
echo -e "*****************************************************************\n"

yum clean all -q
yum remove -y -q $RPMS >/dev/null 2>&1
yum remove -y -q *.i386 >/dev/null 2>&1
echo "Yum cleared. Unused packages and all i386 packages have been removed."

echo -e "\n*****************************************************************"
echo -e "Updating packages.."
echo -e "*****************************************************************\n"

yum -y -q update >/dev/null 2>&1
echo "All installed packages have been updated."

echo -e "\n*****************************************************************"
echo -e "Installing EPEL repo.."
echo -e "*****************************************************************\n"

yum install -y -q $URL/repos/epel-release-6-5.noarch.rpm >/dev/null 2>&1
echo "EPEL repo installed for usefull packages."

echo -e "\n*****************************************************************"
echo -e "Installing usefull packages and directories.."
echo -e "*****************************************************************\n"

yum install -q -y gcc gcc-c++ git htop iftop make nethogs openssh-clients perl screen sysbench subversion >/dev/null 2>&1
echo "Following packages have been installed: gcc gcc-c++ git htop iftop make nethogs openssh-clients perl screen sysbench subversion."
chmod 775 /var/run/screen
mkdir -p /opt/scripts
mkdir -p /opt/src
echo "Directory /opt/scripts and /opt/src created."

echo -e "\n*****************************************************************"
echo -e "Installing Karl's RSA public key and SSH port 2222.."
echo -e "*****************************************************************\n"

mkdir /root/.ssh
echo $sshkey > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
sed -i "s/\#Port\ 22/Port\ 2222/g" /etc/ssh/sshd_config
/etc/init.d/auditd stop >/dev/null 2>&1
/etc/init.d/sshd restart >/dev/null 2>&1
echo "SSH key installed, port 2222 activated, auditd stopped to make SSH key works."

echo -e "\n*****************************************************************"
echo -e "Detecting virtualization and IP"
echo -e "*****************************************************************\n"

### Virtualization ###

yum install -y -q virt-what

VIRT=`virt-what |head -n1`

if [ $VIRT == "xen" ];
	then
    	echo -e "We seem to be on a Xen domU. Checking IP..\n"
elif [ $VIRT == "openvz" ];
	then
    	echo -e "We seem to be on an OpenVZ container. Checking IP..\n"
elif [ $VIRT == "kvm" ];
	then
	    echo -e "We seem to be on KVM. Checking IP..\n"
elif [ $VIRT == "vmware" ];
	then
	    echo -e "We seem to be on VMware. Checking IP..\n"
else
		echo -e "No virtualization detected, we seem to be on a dedicated server. Checking IP..\n"
		VIRT="node"
fi

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

read -p "Script has detected that we are running $VIRT on IP address $IP. Is that correct? (Y/n)" -e VIRT_INPUT

case "$VIRT_INPUT" in
        n)
		read -p "Enter the right virtualization (openvz|xen|kvm|vmware|node):" -e VIRT;
		read -p "Enter the right IP:" -e IP;
		;;
		*)
        ;;
esac

echo -e "\n*****************************************************************"
echo -e "Last configurations depending on virtualization: $VIRT"
echo -e "*****************************************************************\n"

### Guest Server ###

if [ "$VIRT" == "openvz" ] || [ "$VIRT" == "xen" ] || [ "$VIRT" == "kvm" ] || [ "$VIRT" == "vmware" ]; then
	echo "vm.swappiness = 0" >> /etc/sysctl.conf
	echo "Swappiness done."
	wget -q -O /opt/scripts/mysqltuner.pl $URL/scripts/mysqltuner.pl
	chmod +x /opt/scripts/mysqltuner.pl
	echo "MySQL Tuner script done."
	wget -q -O /opt/scripts/backup-mysql.sh $URL/scripts/backup-mysql.sh
	chmod +x /opt/scripts/backup-mysql.sh
	echo "MySQL Backup script done."
fi

if [ "$VIRT" == "vmware" ]; then
	echo "### Need to install vmware tools"
fi


### Node Server ###

if [ "$VIRT" == "node" ]; then
	echo "vm.swappiness = 0" >> /etc/sysctl.conf
	echo "Swappiness done."
	yum install -y -q ebtables
	echo "Ebtables installed, need for IP stealing."
	sed -i "s/\Port\ 2222/Port\ 25000/g" /etc/ssh/sshd_config
	/etc/init.d/sshd restart >/dev/null 2>&1
	echo "SSH port switched to 25000."
fi

### Custom ###

if [ "$VIRT" == "xen" ] || [ "$VIRT" == "kvm" ] || [ "$VIRT" == "vmware" ]; then
	echo -e "\nYou should consider adding the following parameters to grub/fstab: elevator=noop / nohz=off / noatime"
fi

if [ "$VIRT" == "node" ]; then
	echo -e "\nYou should consider adding the following parameters to grub/fstab: elevator=deadline / nohz=off / noatime"
fi



echo -e "\n************************* SUMMARY *******************************"
echo -e "Server: $hostname"
echo -e "Virtualization: $VIRT"
echo -e "IP: $IP\n"
echo -e "CentOS cleaned! What's next?\n"
echo -e "[0] Quit installer"
echo -e "[1] Proceed with cPanel"
echo -e "[2] Proceed with LAMP 53/54/55"
echo -e "[3] Proceed with LAMP 53/54/55 + Nginx"
echo -e "[4] Proceed with LNMP 53/54/55 + PHP-FPM"
echo -e "[5] Proceed with Zimbra"
echo -e "\n*****************************************************************\n"
read -p "Enter action number : " -e PROCEED_INPUT

case "$PROCEED_INPUT" in
        0)
		rm -f /root/centos6.sh;
		exit 0;
		;;
		1)
		cpanel;
		exit 0;
		;;
		*)
        exit 0;
        ;;
esac

}



######## Script Startup ########


echo -e "\n*****************************************************************"
echo -e "CentOS 6 64bits post-installer by kjohnson@aerisnetwork.com"
echo -e "for NEW installation only, hit ctrl-c to cancel."
echo -e "*****************************************************************\n"

INT=3
for i in `seq 1 3`;
do
        sleep 1
        echo -e $INT
        INT=$((INT-1))
done


if [ "$OS1 ${OS2:0:1}" == "CentOS 6" ] && [ "$arch" == "x86_64" ]
then
	echo -e "We are running on CentOS 6 64bits, best OS -.-  we can continue ..\n"
	cleanup
else
	echo -e "Not on CentOS 6 64bits, please reinstall.\n"
fi

