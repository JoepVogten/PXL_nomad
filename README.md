# Nomad consul

The aim of this project is to provide a development environment based on [consul](https://www.consul.io) and [nomad](https://www.nomadproject.io) to manage container based microservices.

The following steps should make that clear;

bring up the environment by using [vagrant](https://www.vagrantup.com) which will create centos 7 virtualbox machine or lxc container.

The proved working vagrant providers used on an [ArchLinux](https://www.archlinux.org/) system are
* [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc)
* [vagrant-libvirt](https://github.com/vagrant-libvirt/)
* [virtualbox](https://www.virtualbox.org/)

```bash
    $ vagrant up --provider lxc
    OR
    $ vagrant up --provider libvirt
    OR
    $ vagrant up --provider virtualbox
```

Once it is finished, you should be able to connect to the vagrant environment through SSH and interact with Nomad:

```bash
    $ vagrant ssh
    [vagrant@nomad ~]$
```

# VAGRANTFILE
Met de vagrantfile kunnen we een configuratie meegeven voor het opspinnen van verschillende vm's. Met mijn vagrantfile worden er 2 clients opgestart en 1 server. Ik laat de updatescript runnen en daarna de aangemaakte installScript. Daarna maak ik expliciet 3 vm's aan, waar ik een vast ip-adres aan toeken en waar ik een script aan meegeef die later in de documentatie nog besproken wordt.

```# -*- mode: ruby -*-
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
```
