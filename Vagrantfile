# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rubygems'
require 'bundler'

Bundler.require
require 'multi_json'

Vagrant::Config.run do |config|
  config.vm.box = "centos"

  config.vm.box_url = "https://s3.amazonaws.com/itmat-public/centos-6.3-chef-10.14.2.box"

  # Boot with a GUI so you can see the screen. (Default is headless)
  # config.vm.boot_mode = :gui

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  config.vm.forward_port 80, 4000

  VAGRANT_JSON = MultiJson.load(Pathname(__FILE__).dirname.join('nodes', 'vagrant.json').read)

  config.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = ["site-cookbooks", "cookbooks"]
     chef.roles_path = "roles"
     chef.data_bags_path = "data_bags"
     chef.provisioning_path = "/tmp/vagrant-chef"

     # You may also specify custom JSON attributes:
     chef.json = VAGRANT_JSON
     VAGRANT_JSON['run_list'].each do |recipe|
      chef.add_recipe(recipe)
     end if VAGRANT_JSON['run_list']
  end

end
