# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provision "shell", path: "ansible/installAnsible.sh"
  config.vm.box = "centos/7"

  config.vm.define "server" do |server|
    server.vm.hostname = "SERVER"
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
#        "server" => {"software__content" => "server_value"}
      }
#      ansible.verbose = '-vvv'
    end
  end

  config.vm.define "agent1" do |agent1|
    agent1.vm.hostname = "AGENT1"
    agent1.vm.network "private_network", ip: "192.168.1.3"
	
	agent1.vm.provision "ansible_local" do |ansible|
      ansible.config_file = "ansible/ansible/ansible.cfg"
      ansible.playbook = "ansible/ansible/plays/agent.yml"
      ansible.groups = {
        "agents" => ["agent1"],
#        "agents:vars" => {"software__content" => "agents_value"}
      }
      ansible.host_vars = {
#        "agent1" => {"software__content" => "agent1_value"}
      }
#      ansible.verbose = '-vvv'
    end
  end

  config.vm.define "agent2" do |agent2|
    agent2.vm.hostname = "AGENT2"
    agent2.vm.network "private_network", ip: "192.168.1.4"
	
	agent2.vm.provision "ansible_local" do |ansible|
      ansible.config_file = "ansible/ansible/ansible.cfg"
      ansible.playbook = "ansible/ansible/plays/agent.yml"
      ansible.groups = {
        "agents" => ["agent2"],
#        "agents:vars" => {"software__content" => "agents_value"}
      }
      ansible.host_vars = {
#        "agent2" => {"software__content" => "agent2_value"}
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
