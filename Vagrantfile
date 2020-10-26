# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos/7"
  config.vm.provision "shell", path: "scripts/update.sh"
  config.vm.provision "shell", path: "script/installScript.sh"

  config.vm.define "server" do |server|
    server.vm.hostname = "SERVER"
    server.vm.provision "shell", path: "scripts/Server.sh"
    server.vm.network "private_network", ip: "192.168.1.2"
  end
  
   config.vm.define "Client1" do |client1|
    agent1.vm.hostname = "CLIENT1"
    agent1.vm.provision "shell", path: "scripts/Client1.sh"
    agent1.vm.network "private_network", ip: "192.168.1.3"
  end

  config.vm.define "Client2" do |client2|
    agent2.vm.hostname = "CLIENT2"
    agent2.vm.provision "shell", path: "scripts/Client2.sh"
    agent2.vm.network "private_network", ip: "192.168.1.4"
  end
  
  config.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-7.x-minimal"
  end
  
end
