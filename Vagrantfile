# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # config.vbguest.auto_update = false (werkt niet?)
  config.vm.box = "centos/7"
  config.vm.provision "shell", path: "ansible/installAns.sh"
  
  config.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-7.x-minimal"
  end

  config.vm.define "server" do |server|
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.1.2"
    server.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true, host_ip: "127.0.0.1"
	  server.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
	  server.vm.network "forwarded_port", guest: 9090, host: 9090, auto_correct: true, host_ip: "127.0.0.1"

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

  (1..2).each do |i|
    config.vm.define "client#{i}" do |client|
      client.vm.hostname = "client#{i}"
      client.vm.network "private_network", ip: "192.168.1.#{i+2}"
      client.vm.provision "ansible_local" do |ansible|
        ansible.config_file = "ansible/ansible/ansible.cfg"
        ansible.playbook = "ansible/ansible/plays/client.yml"
        ansible.groups = {
          "clients" => ["client#{i}"],
#         "clients:vars" => {"software__content" => "clients_value"}
        }
        ansible.host_vars = {
#          "client#{i}" => {"software__content" => "client#{i}_value"}
        }
#       ansible.verbose = '-vvv'
      end
    end
  end
end
