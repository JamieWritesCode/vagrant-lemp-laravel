# Vagrant LEMP Stack for Laravel

A simple Vagrantfile and bootstrap script that installs a Vagrant box suitable for deploying a Laravel/Lumen installation.

### What's installed?
* Ubuntu 16.04
* nginx
* MySQL 5.7
* PHP 7.2
* git
* Composer
* laravel/installer

### Why use this instead of Laravel Homestead?

Laravel Homestead provides a comprehensive solution to running Laravel with Vagrant on your local machine however, I found its configuration slightly overkill. Instead, I've opted for a simple, single site install rather than supporting multiple projects within the same Vagrant instance.

Note that this configuration does not include Node.JS, Redis, Memcache etc. These will need to be installed manually when required.

### How to use?

Use `vagrant box add ubuntu/xenial64` to download and install vagrant image.

Put `Vagrantfile` and `bootstrap.sh` inside a folder and do a `vagrant up` on the command line.

Once Vagrant is provisioned, SSH into your box using `vagrant ssh` and `cd /var/www/html` to change to the correct working directory .

Run `composer global require "laravel/installer"` to setup the installer. 

Finally, `laravel new` creates a blank application.

Your new vagrant box will be running at IP `192.168.33.22`. You may want to add this to your hosts file.

MySQL root password will be `password` and default database will be `database`.