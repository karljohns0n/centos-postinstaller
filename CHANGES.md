## 2.31 ##

- Initial version on GIT
- S'inspirer du script CentOS 5 pour partir la base du script de CentOS 6
- Installer automatiquement EPEL et désactiver post-install
- Installer les extras packages: htop, screen, perl, git, iftop, nethogs
- Installer cle ssh
- Supprimer xinetd samba* php*
- Changer la cle ssh
- Ajouter openssh-clients pour scp
- Rediriger les commandes qui peuvent avoir des erreurs vers >/dev/null 2>&1
- Trouver si c'est un openvz ou xen et mettre le IP en variable
- Ajouter poursuivre avec cPanel
- Ajouter backup MySQL et mysqltunner et apache-top.py (cpanel)
- Ajouter optimisation de base MySQL (cPanel)
- Ajouter les alias profile pour cPanel (apachelogs. eximlogs)
- Tout tester sur core1 (pour openvz) et core2 (pour xen)
