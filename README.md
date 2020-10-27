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

# installScript.sh
Het installscript is een algemeen bestand met de installatie van nomad, consul en docker. Dit bestand wordt gerunned in de vagrantfile. Ik heb dit bestand gemaakt omdat deze drie features op alle vm's geinstalleerd moeten worden.

```#!/bin/bash

#install utils and add repo
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

#install Nomad
sudo yum install -y nomad

systemctl enable nomad
systemctl start nomad

#install Consul
sudo yum install -y consul

systemctl enable consul
systemctl start consul

#install Docker
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io

systemctl enable docker
systemctl start docker
```

# Server.sh
Dit is het script voor het opspinnen van de server. Ik heb ervoor gekozen om de algemene configfile te verwijderen en daarna een nieuwe aan te maken met een unieke naam. ook heb ik een map aangemaakt voor de data. Ik geef nomad een vast ip-adres en stop de data in de aangemaakte data_directory. Ik geef aan dat het om een server gaat en geef ook een naam mee. Voor consul is dit ongeveer dezelfde werking als bij nomad. tenslotte herstart ik nomad en consul met systemctl.

```#!/bin/bash

#NOMAD
#deleting the default systemd config file for nomad
sudo rm -f /etc/nomad.d/nomad.hcl

#making a directory for the data
sudo mkdir /opt/nomad/server

cat << END >/etc/nomad.d/server.hcl
bind_addr = "192.168.1.2"
data_dir = "/opt/nomad/server"
name = "server"
server {
  enabled = true
  bootstrap_expect = 1
}
END

#CONSUL
#deleting the default systemd config file for consul
sudo rm -f /etc/consul.d/consul.hcl

#making a directory for the data
sudo mkdir /opt/consul/server

cat << END >/etc/consul.d/server.hcl
bind_addr = "192.168.1.2"
client_addr = "0.0.0.0"
data_dir = "/opt/nomad/server"
ui = true
bootstrap_expect = 1
END

systemctl daemon-reload
systemctl restart nomad
systemctl restart consul
```

# Client 1
Zoals bij de server maken we bij de clients een nieuwe configfile aan. We geven nomad een naam mee, een data directory, een vast ip-adres en geven aan dat het een client en daarbinnen welke server die gebruikt. Ik doe hetzelfde voor consul. Dan herstart ik beide services weer.

```#!/bin/bash

#NOMAD
#deleting the default systemd config file for nomad
sudo rm -f /etc/nomad.d/nomad.hcl

#making a directory for the data
sudo mkdir /opt/nomad/client1

#making a new one
cat << END >/etc/nomad.d/client1.hcl
name = "client1"
data_dir = "/opt/nomad/client1"
bind_addr = "192.168.1.3"
client {
    enabled = true
    servers = ["192.168.1.2:4647"]    
}
END

#CONSUL
#deleting the default systemd config file for consul
sudo rm -f /etc/consul.d/consul.hcl

#making a directory for the data
sudo mkdir /opt/consul/client1

#making a new one
cat << END >/etc/consul.d/client1.hcl
data_dir = "/opt/consul/client1"
bind_addr = "192.168.1.3"
client_addr = "0.0.0.0"
ui = true
retry_join = ["192.168.1.2"]
END

#restarting all services
systemctl daemon-reload
systemctl restart nomad
systemctl restart consul
```

# Client 2
Idem als bij client 1, enkel met een ander ip-adres.

```#!/bin/bash

#NOMAD
#deleting the default systemd config file for nomad
sudo rm -f /etc/nomad.d/nomad.hcl

#making a directory for the data
sudo mkdir /opt/nomad/client2

#making a new one
cat << END >/etc/nomad.d/client2.hcl
name = "client2"
data_dir = "/opt/nomad/client2"
bind_addr = "192.168.1.4"
client {
    enabled = true
    servers = ["192.168.1.2:4647"]    
}
END

#CONSUL
#deleting the default systemd config file for consul
sudo rm -f /etc/consul.d/consul.hcl

#making a directory for the data
sudo mkdir /opt/consul/client2

#making a new one
cat << END >/etc/consul.d/client2.hcl
data_dir = "/opt/consul/client2"
bind_addr = "192.168.1.4"
client_addr = "0.0.0.0"
ui = true
retry_join = ["192.168.1.2"]
END

#restarting all services
systemctl daemon-reload
systemctl restart nomad
systemctl restart consul
```

# Update script
Met dit script word er gekeken of het systeem geupdated moet worden.

```#!/bin/bash

availableUpdates=$(sudo yum -q check-update | wc -l)

if [ $availableUpdates -gt 0 ]; then
    sudo yum upgrade -y;
else
    echo $availableUpdates "updates available"
fi
```

# Webserver job
Ik maak een directory aan onder /opt namelijk nomad. Hier maak ik een webserver-job in aan genaamd job.nomad. Het gaat om een nginx webserver.

```sudo mkdir /opt/nomad
sudo cat << END >/opt/nomad/job.nomad
job "webserver" {
  datacenters = ["dc1"]
  type = "service"
  
  group "webserver" {
  
    task "webserver" {
      driver = "docker"
      config {
        image = "nginx"
		    force_pull = true
		    port_map = {
		    webserver_web = 80
		} 
		logging {
		  type = "journald"
		  config {
		    tag = "WEBSERVER"
		 }
		}	
      }
	  
	  service {
	    name = "webserver"
	    port = "webserver_web"
	  } 
      resources {
        network {
          port "webserver_web" {
            static = "8000"
          }
        }
      }
    }
  }
}
END
```
