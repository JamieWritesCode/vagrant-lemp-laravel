# Vagrant LEMP Stack for Laravel

A simple Vagrantfile and bootstrap script that installs a Vagrant box suitable for deploying a Laravel installation.

###What's installed?
* PHP 7
* nginx
* MariaDB
* git
* Composer
* laravel/installer
* Basic SFTP backup script

Put `Vagrantfile` and `bootstrap.sh` inside a folder and do a `vagrant up` on the command line.
This box uses Ubuntu 14.04 LTS "Trustry Thar" 64bit, so if you don't have the basic box already, do a 
`vagrant box add ubuntu/trusty64` before.

Once Vagrant is provisioned, SSH into your box and `cd /var/www/html` to change to working directory then `composer global require "laravel/installer"` to setup the installer. Finally, `laravel new` creates a blank application.