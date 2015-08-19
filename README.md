# CentOS Post-Installation and useful scripts
### by Karl Johnson -- karljohnson.it@gmail.com -- kj @ Freenode

CentOS post-installer was originally a script that I use when provisioning fast Xen and OpenVZ servers so it works well with OpenVZ/Xen official templates. It takes very few minutes to have an optmized OS and a full LEMP stack (latest Nginx, PHP, MySQL and PageSpeed versions) installed with a first Website configured. I haven't maintained those scripts a lot since CentOS 7 release but I should start working on it soon after I publish it from private BitBucket to public GitHub. Run only the post-installation script on a brand new VM. It has been used in production for 2 years now!

## Builds

### Cleanup

This script assume that we are on a brand new server, it's really important as some packages will be removed.

* Disable SELinux, set Timezone, disable useless services
* Remove unused packages and update OS
* Install a SSH key and switch SSH port (2222 for vm, 25000 for node)
* Install useful packages
* Install Aeris and EPEL repos
* Create directories in /opt
* Detect virtualization/node and IP for custom optimization
* Quick benchmarks

### LEMP

This script will install Nginx with PageSpeed and will let you choose between PHP 5.3/5.4/5.5/5.6. It will also let you install MySQL 5.6 or MariaDB 10.

* Nginx-more (latest Nginx, OpenSSL, PageSpeed, ModSecurity, More-Headers, Cache Purge, etc..)
* PHP 5.3, 5.4, 5.5, 5.6
* PHP-FPM, OPcache & Memcached
* PHP sessions in Memcached
* MySQL 5.6 or MariaDB 10
* VsFTPd with virtual users
* PhpMyAdmin
* Monit

### cPanel

This script will install the latest version of cPanel.

* Install RELEASE version of cPanel
* Disable optimizefs
* Optimize MySQL
* Add useful aliases

### FreePBX

This script will install version 2.11 of FreePBX and Asterisk 11 from AsteriskNOW centos repository.

* Prepare server for installation
* Install latest version from AsteriskNOW
* Install FreePBX version 2.11 from the upstream website
* Basic configurations

### Scripts

* Basic MySQL backup & optimize
* WordPress search, show version and secure wp-config.php (cPanel only)
* Nginx cache cleaner
* LSI MegaRAID report for device and hard drives health. Compatible with SATA and SAS.

## Todo

* Post-installer for CentOS 7
* Zimbra build
* LEMH build (HHVM!)
* Varnish setup for cPanel