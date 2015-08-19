## 2.0.0 - 2015/08/19

- Major cleanup in CentOS 6 post-installer and several scripts
- Apache removed from the LAMP build, only LEMP anymore
- Add OPcache module for LEMP
- Remove built-in PHP/MySQL option. Only packages from IUS including PHP53 as archive
- Add RapidSSL 256bits CA bundles (useful for nginx-more and most of my customers!)
- Specify SSH key in the builder
- Add proxy cache path in cleannginxcache script
- Removing Munin from builder, not using it anymore
- Fetch mysqltunner directly from github
- Put PHP sessions in memcached
- Configure monit services for LEMP
- Add a progression bar for cleanup and lemp functions
- Remove the useless startup spinner
- Bump PMA to latest release URL
- Bump IUS and EPEL RPMs to latest

## 1.35 - 2014/12/04

- Show menu first instead of cleaning at start
- Add verify dependencies checkup function
- Add Aeris repo
- Add new cpwpcheck.sh script to list all WP versions on cPanel servers and chmod wp-config.php
- Updating doc for MySQL 5.6. Add PageSpeed flush cache
- Switch MySQL 5.5 to 5.6. Configure log file in variable
- Add new script to clean Nginx cache
- Cleanup in centos6.sh. Change vm.swapiness to 1 instead of 0. Add new useful packages
- Replace Sendmail by Postfix. Benchmark IO/Net/CPU. Code cleanup
- Add PHP 5.6 to webkit el6
- Add Nginx option to webkit el6
- Code cleanup
- Refresh ius and epel repo rpm
- Refresh PMA to upstream 4.2.12

## 1.34 - 2014/04/04

- Removing support for CentOS 5
- MariaDB integration for LAMP
- Send email report after cleanup

## 1.33 - 2014/03/19

- FreePBX installer
- Minor changes in the code

## 1.32 - 2014/03/18

- Quiet cleanup output
- Few code optimization
- More verbose during the progress
- Timezone configuration
- Ethtool configuration if Xen/KVM/Vmware
- Add optimizefsdisable for cPanel
- Additionnal notes if server is a node

## 1.31 - 2014/03/12

- Base new CentOS 6 script on the CentOS 5 script
- Install the EPEL repos
- Install extra packages: htop, screen, perl, git, iftop, nethogs, etc..
- Install SSH key
- Uninstall: xinetd samba* php*
- Change SSH Key for the new one
- Install openssh-clients for scp
- Find virtualization and IP
- cPanel installer
- Add backup MySQL, mysqltunner and apache-top.py (cpanel only)
- MySQL Optimization (cPanel)
- Add alias profile for cPanel (apachelogs. eximlogs)

## 1.30 - 2013/06/04
- Initial version on GIT @ Bitbucket