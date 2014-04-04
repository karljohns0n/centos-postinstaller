# CentOS 6 Builder
### by Karl Johnson - kjohnson@aerisnetwork.com

## Build

### Cleanup

This script is started automatically if the OS is CentOS 6 64bits to clean it. This script assume that we are on a brand new server, it's really important as some packages will be removed.

* Disable SELinux, set Timezone, disable useless services
* Remove unused packages and update OS
* Install Karl's SSH keys and switch SSH port
* Install usefull packages
* Create directories in /opt
* Detect virtualization and IP for custom rules

### cPanel

This script will install the latest stable version of cPanel.

* Install latest RELEASE version of cPanel
* Disable optimizefs
* Optimize MySQL
* Add usefull alias

### LAMP

This script will let you choose between PHP 5.3 5.4 5.5 and the one built-in in the OS. It will also let you install MySQL 5.5 and MariaDB 10.

* Apache
* PHP built-in|53|54|55
* MySQL built-in|55|mariadb10
* VsFTPd
* Munin
* Monit

### FreePBX

This script will install version 2.11 of FreePBX and Asterisk 11 from AsteriskNOW centos repository.

* Prepare server for installation
* Install latest version from AsteriskNOW
* Install FreePBX version 2.11 from the upstream website
* Basic configurations

It's important to keep the URL of FreePBX archive and AsteriskNOW repo updated.
