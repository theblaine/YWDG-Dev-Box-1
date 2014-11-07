# setup default path
Exec {
path => ["/usr/bin", "/bin", "/usr/sbin", "/sbin", "/usr/local/bin", "/usr/local/sbin",""]
}

group {
"puppet":
ensure=>"present"
}

exec{
"apt-get update":
command=>"/usr/bin/apt-get update",
}

# package install list for tools
$tools_packages=[
"git",
"curl",
"wget",
"vim",
"htop",
"screen",
"nmon",
"iftop",
"collectl",
"iptraf",
"software-properties-common",
"python-software-properties",
"build-essential",
"libssl-dev",
"sqlite3",
"libsqlite3-dev",
"libyaml-dev",
"libxml2",
"libxslt-dev"

]

# install tool packages
package {$tools_packages:
ensure=> present,
require=>Exec["apt-get update"]
}

# install apache
package{"apache2":
ensure=>present,
require=>Exec["apt-get update"]
}

# ensures that mode_rewrite is loaded and modifies the default configuration file
file { "/etc/apache2/mods-enabled/rewrite.load":
ensure => link,
target => "/etc/apache2/mods-available/rewrite.load",
require => Package["apache2"]
}

# create directory
file {"/etc/apache2/sites-enabled":
ensure => directory,
recurse => true,
purge => true,
force => true,
before => File["/etc/apache2/sites-enabled/vagrant_webroot"],
require => Package["apache2"],
}

# create apache config from main vagrant manifests
file { "/etc/apache2/sites-available/vagrant_webroot":
ensure => present,
source => "/vagrant/manifests/vagrant_webroot",
require => Package["apache2"],
}

# symlink apache site to the site-enabled directory
file { "/etc/apache2/sites-enabled/vagrant_webroot":
ensure => link,
target => "/etc/apache2/sites-available/vagrant_webroot",
require => File["/etc/apache2/sites-available/vagrant_webroot"],
notify => Service["apache2"],
}

# starts the apache2 service once the packages installed, and monitors changes to its configuration files and reloads if nesessary
service { "apache2":
ensure => running,
require => Package["apache2"],
subscribe => [
File["/etc/apache2/mods-enabled/rewrite.load"],
File["/etc/apache2/sites-available/vagrant_webroot"]
],
}


# root mysql password
$mysqlpw = "d3v0p5"

# install mysql server
package {"mysql-server":
ensure=>present,
require=>Exec["apt-get update"],
}->

# start mysql service
service {"mysql":
ensure=>running,
require=>Package["mysql-server"],
}->

# set mysql password
exec {"set-mysql-password":
unless=>"mysqladmin -uroot -p$mysqlpw status",
command=>"mysqladmin -uroot password $mysqlpw",
require=>Service["mysql"],
}

# package install list for PHP
$php_packages = [
"php5","php5-cli","php5-mysql","php-pear","php5-dev","php5-gd","php5-mcrypt","libapache2-mod-php5"
]

package {$php_packages:
ensure=>present,
require=>Exec["apt-get update"],
}->

# upgrade PEAR
exec { "pear upgrade":
require => Package["php-pear"]
}

# install PHPUnit
exec { "pear config-set auto_discover 1":
require => Exec["pear upgrade"]
}

# create pear temp directory for channel-add
file { "/tmp/pear/temp":
require => Exec["pear config-set auto_discover 1"],
ensure => "directory",
owner => "root",
group => "root",
mode => 777
}

# discover channels
exec { "pear channel-discover pear.phpunit.de; true":
require => [File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
}

exec { "pear channel-discover pear.symfony-project.com; true":
require => [File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
}

exec { "pear channel-discover components.ez.no; true":
require => [File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
}

exec{"pear channel-discover pear.phpdoc.org; true":
	require=>[File["/tmp/pear/temp"], Exec["pear config-set auto_discover 1"]]
}


# clear cache before install phpunit
exec { "pear clear-cache":
require => [Exec["pear channel-discover pear.phpunit.de; true"], Exec["pear channel-discover pear.symfony-project.com; true"], Exec["pear channel-discover components.ez.no; true"], Exec["pear channel-discover pear.phpdoc.org; true"]],
}

# install phpunit
exec { "pear install -a -f phpunit/PHPUnit":
require => Exec["pear clear-cache"]
}

#install phpdoc

exec{"pear install -a -f phpdoc/phpDocumentor; true":
	require=>Exec["pear clear-cache"],
}

#install composer
exec{'download_composer':
user=>'root',
command=>"curl -sS https://getcomposer.org/installer | php",
require=>[Package["curl"],Exec["apt-get update"],Package["php5"]],
}->
exec{'move_composer_to_bin':
user=>'root',
command=>"sudo mv composer.phar /usr/local/bin/composer",
require=>[Exec["apt-get update"], Exec['download_composer']],
}

# install PostgreSQL
exec{'PostgreSQL':
user=>'root',
command=>"sudo apt-get install postgresql postgresql-contrib -y",
require=>Exec["apt-get update"],
}

# package install for ruby
$ruby_packages = [
"ruby1.9.3","rubygems"
]

exec{'rails_uninstall':
  user=>'root',
  command=>"sudo apt-get remove --purge ruby1.8 -y",
  require=>Exec["apt-get update"],
}->


package{$ruby_packages:
ensure=>present,
require=>Exec["apt-get update"],
}

exec{'gem1':
user=>'root',
command=>"gem install cyaml --no-ri --no-rdoc; echo $?",
require=>[Exec["apt-get update"],Package["ruby1.9.3"],Package["rubygems"]],
}->

exec{'gem2':
user=>'root',
command=>"gem install bundler --no-ri --no-rdoc; echo $?",
require=>[Exec["apt-get update"],Package["ruby1.9.3"],Package["rubygems"]],
}->

exec{'gem3':
user=>'root',
command=>"gem install rails; echo $?",
require=>[Exec["apt-get update"],Package["ruby1.9.3"],Package["rubygems"]],
}


# package install list for flask
$flask_packages = [
"python-pip"
]

# install packages for flask
package{$flask_packages:
ensure=>present,
require=>Exec["apt-get update"],
}

#install flask
exec{"pip install Flask":
user=>"root",
require=>[Exec["apt-get update"], Package["python-pip"]],
}

# install SQLAlchemy
exec{"pip install SQLAlchemy":
user=>"root",
require=>[Exec["apt-get update"], Package["python-pip"]],
}

exec{"curl -sL https://deb.nodesource.com/setup | sudo bash -":
require=>Package["curl"],
}

exec{"add-apt-repository ppa:chris-lea/node.js":
require=>Exec["apt-get update"]
}

exec{"apt-get install nodejs -y":
user=>"root",
require=>[Exec["curl -sL https://deb.nodesource.com/setup | sudo bash -"],Exec["add-apt-repository ppa:chris-lea/node.js"],Exec["apt-get update"]],
}

# install npm
exec {"apt-get install npm -y; echo $?":
logoutput=>on_failure,
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get update"]],
}

file { "/usr/bin/node":
ensure => link,
target => "/usr/bin/nodejs",
}

# install mongodb
exec{"apt-get install mongodb -y":
require=>Exec["apt-get update"],
}

exec{"npm config set registry http://registry.npmjs.org/":
require=>[Exec["apt-get install npm -y; echo $?"],Exec["apt-get update"]]
}

# install npm packages
exec{"npm install -g grunt-cli":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g grunt":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g bower":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g yo":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g mongodb":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g angularjs":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g express":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g express-generator":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g mocha":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g chai":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g nodemon":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g winston":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g crypto":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}


exec{"npm install -g phantomjs":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g connect":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g forever":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}

exec{"npm install -g forever-monitor":
require=>[Exec["apt-get install nodejs -y"], Exec["apt-get install npm -y; echo $?"],Exec["npm config set registry http://registry.npmjs.org/"],Exec["apt-get update"]]
}