#&lt;YourWebDevGuy/&gt; Dev-Box

I'm a webdeveloper who loves coding with PHP, Javascript, Python and Ruby. I couldn't find a VM (turnkeylinux.org or box on Vagrantbox.es) that had what I was looking for so I built it.
With this VagrantFile you get some of my favorite and most used tools including:

#### LAMP
-> Ubuntu, Apache, MySQL (user:root  pass:d3v0p5), PHP (plus goodies: phpunit, phpdoc, composer, pear)

#### MEAN 
-> MongoDB, Angular.js, Express.js, Node.js, (plus goodies: Mocha, Chai, Nodemon, Forever, Winston, Yeoman, Phantom.js)

#### Flask
-> Python, Flask, SQLAlchemy

#### Rails
-> Ruby, RubyGems, Rails

#### Linux Tools
-> git, curl, vim, htop, iftop, nmon, iptraf, collectl, screen

## Get Started
- Download and Install Virtualbox (http://virtualbox.org)
- Download and install Vagrant (http://vagrantup.com)
- Clone this Repo (git clone git://github.com/abrahamcuenca/YWDG-Dev-Box.git)
- Run: vagrant up
- Run: vagrant ssh
- 
---

### Basic Vagrant Commands

> Start Server:  <br/> vagrant up

> Pause Server: <br/> vagrant suspend

> Delete Server: <br/>  vagrant destroy

> SSH into the Server: </br> vagrant ssh

_Note: Both Node.js and Rails use port 3000 you cannot run both simultanously without changing the port<br/> Due to the way Virtualbox sets up the shared folders symlinks do not work well with Nodejs (exress framework) it is best to create nodejs apps outside of the share folder (e.g. in your home directory or elsewhere)_ 

### Mapped Ports
- Vagrant Box:80 -> Host:8888 (used by PHP)
- Vagrant Box:3000 -> Host:3000 (used by either NodeJS or RubyOnRails)
- Vagrant Box:5000 -> Host:5000 (used by Flask)
- Vagrant Box:3306 -> Host:3306 (used by MySQL) *
- Vagrant Box:27017 -> Host:27107 (used by MongoDB) *
- Vagrant Box:27017 -> Host:5432 (used by MongoDB) *

---

### Todo:

1. Split puppet file into modules
2. clean up code
3.  * Bind Mongodb from 127.0.0.1 to 0.0.0.0 to allow external connections
4.  * Bind MySQL from 127.0.0.1 to 0.0.0.0 to allow external connections
5.  * Bind PostgreSQL from 127.0.0.1 to 0.0.0.0 to allow external connections
