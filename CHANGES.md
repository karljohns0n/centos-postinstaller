## 2.33 - 2014/03/19 ##

- FreePBX integration
- Minor changes in the code

## 2.32 - 2014/03/18 ##

- Quiet cleanup; redirect output to >/dev/null 2>&1 and use -q for yum
- Few code optimization
- More comments during the progress
- Timezone configuration
- Ethtool configuration if Xen/KVM/Vmware
- Add optimizefsdisable for cPanel
- More additionnal notes if server is node
- VMware-tools install in progress..

## 2.31 - 2014/03/12 ##

- Initial version on GIT
- Base this new CentOS 6 script on the CentOS 5 script
- Install the EPEL repos
- Install extra packages: htop, screen, perl, git, iftop, nethogs, etc..
- Install SSH key
- Uninstall: xinetd samba* php*
- Change SSH Key for the new one
- Install openssh-clients for scp
- Find virtualization and IP
- cPanel installer
- Add  backup MySQL, mysqltunner and apache-top.py (cpanel only)
- MySQL Optimization (cPanel)
- Add alias profile for cPanel (apachelogs. eximlogs)
