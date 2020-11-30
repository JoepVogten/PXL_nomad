# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "centos/7"
  config.vbguest.auto_update = false
  config.vm.provision "shell", path: "installAns.sh"

  config.vm.define :server do |server|
    server.vm.hostname = "server"
    server.vm.network = "private_network", ip: "192.168.1.2"

    server.vm.provision "ansible_local" do |ansible|
      ansible.config_file = "ansible/ansible/ansible.cfg"
      ansible.playbook = "ansible/ansible/plays/server.yml"
      ansible.groups = {
        "servers" => ["server"],
#        "servers:vars" => {"software__content" => "servers_value"} 
      }
      ansible.host_vars = {
#        "server" => {"software__content" => "servers_value"}
      }
#      ansible.verbose = '-vvv'
    end
  end

  
  
  config.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-7.x-minimal"
  end
  
end
