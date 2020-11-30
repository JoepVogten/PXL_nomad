# Ansible
Ansible binnen mijn infrastructuur

# VAGRANTFILE
Met de vagrantfile kunnen we een configuratie meegeven voor het opspinnen van verschillende vm's. In deze vagrantfile geef ik aan dat er 3 vm's worden opgespinned. in dit geval 1 server en 2 clients erbij. Ik heb een scriptje gemaakt waarmee ik ansible installeer omdat dit toch in alle 3 de vm's moet gebeuren. De eerste vm die aangemaakt wordt is de server-vm. ik ken het ip 192.168.1.2 toe aan de server. Daarna komt de ansible provision waarbij we niet ansible maar ansible_local moet gebruiken aangezien ik op een windowsmachine te werk ben gegaan. ik geef configfile en playbook en de groups mee. Dit doen we ook voor 2 clients. Deze heb ik in een loop gezet zodat dit niet 2x geschreven moet worden. we gebruiken hier dezelfde configfile maar een ander playbook. De files worden verder in de documentatie besproken.
```# -*- mode: ruby -*-
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
  
  config.vm.provider :virtualbox do |virtualbox, override|
    virtualbox.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.provider :lxc do |lxc, override|
    override.vm.box = "visibilityspots/centos-7.x-minimal"
  end
  
end
```
# installAns.sh
Met deze script installeer ik ansible op de vm's.
```#!/bin/bash
sudo yum install epel-release -y
sudo yum install ansible -y
```

# playbook
# (server)
Dit is de ansible playbook voor de server. hier geef je verschillende rollen aan mee zodat ansible deze kan deployen. Ik geef de role docker, consul en nomad mee die later ook besproken worden. 
```---
- name: playbook for server vm
  hosts: servers
  become: yes

  roles:
    - role: software/docker
    - role: software/consul
    - role: software/nomad
```
# (client)
Hetzelfde als bij de server, alleen in dit geval gebruik ik clients i.p.v. servers
```---
- name: playbook for client vm
  hosts: clients
  become: yes

  roles:
    - role: software/docker
    - role: software/consul
    - role: software/nomad
```

# Gebruikte bronnen
-slides uit de les
-
