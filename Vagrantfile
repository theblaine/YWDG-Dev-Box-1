Vagrant.configure("2") do |config|

  # Enable the Puppet provisioner, with will look in manifests
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests" 
    puppet.manifest_file = "ywdg.pp"
    # puppet.options = "--verbose --debug"
  end

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise32"

  # Forward guest Apache port 80 to host port 8888 and name mapping
  config.vm.network :forwarded_port, guest: 80, host: 8888 
  # Forward guest Node.js/Ruby port 3000 to host port 3000 and name mapping
  config.vm.network :forwarded_port, guest: 3000, host: 3000
  # Forward guest Flask port 5000 to host port 5000 and name mapping
  config.vm.network :forwarded_port, guest: 5000, host: 5000
  # Forward guest MySQL port 5000 to host port 5000 and name mapping
  config.vm.network :forwarded_port, guest: 3306, host: 3306
  # Forward guest MongoDB port 5000 to host port 5000 and name mapping
  config.vm.network :forwarded_port, guest: 27017, host: 27017
# Forward guest PostgreSQL port 5432 to host port 5432 and name mapping
  config.vm.network :forwarded_port, guest: 5432, host: 5432


  config.vm.synced_folder "webroot/", "/vagrant/webroot/", :owner => "www-data"
end
