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
Hetzelfde als bij de server, alleen in dit geval gebruik ik clients i.p.v. servers.
```---
- name: playbook for client vm
  hosts: clients
  become: yes

  roles:
    - role: software/docker
    - role: software/consul
    - role: software/nomad
```

# Roles
# Nomad
# handlers
Ik geef mee dat de nomad service herstart moet worden. We gebruiken deze handler later opnieuw.
```---
- name: restart nomad
  service:
    name: nomad
    state: restarted
```

# tasks
Eerst voeg ik de hashicorp repo toe. Nu installeer ik nomad en voeg ik het nomad-script toe. Ik geef eigenlijk de template mee voor het script. Het script wordt later besproken. verder geef ik de owner nog mee en ook de rechten. De laatste task is het enablen van de service door de bovenstaande handler te gebruiken.
```---
- name: add repo
  command: yum-config-manager --add-repo=https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

- name: install nomad
  yum:
    name: nomad
    state: installed

- name: add nomad script
  template:
    src: nomad.sh.j2
    dest: /etc/nomad.d/nomad.hc1
    owner: "root"
    group: "root"
    mode: 0744

- name: enable service nomad
  service:
    name: nomad
    enabled: yes
  notify: restart nomad
```

# templates
Dit is de template van de nomad.hcl file. we geven eerst de variabele bind_addr mee en de data dir. Ook zet ik het log_level op debug. Via een if kijken we of de VM een server is of een client. In het eerste geval zou het een server zijn en dan krijgt deze de naam server en wordt de bootstrap_expect op 1 gezet. In het tweede geval is het een client. Deze krijgt het ip van de server maar om de naam te bepalen gebruik ik een nieuwe if-structuur. Omdat ik hier maar 2 clients heb kan ik deze if gebruiken, mochten dit er meer worden moet de if aangepast worden.
```#!/bin/bash
# {{ ansible_managed }}

bind_addr = {{ ansible_eth1.ipv4.address }}
data_dir = "/opt/nomad"
log_level = "DEBUG"

{% if ansible_hostname == 'SERVER' %}
    name = "server"
    server {
        enabled = true
        bootstrap_expect = 1
    }
{% else %}
    client {
        enabled = true
        servers = ["192.168.1.2"]
    }

    {% if ansible_hostname == 'CLIENT1' %}
        name = "client1"
    {% else %}
        name = "client2"
    {% endif %}
{% endif %}
```

# Consul
# handlers
Idem als bij nomad maar dan voor consul-service.
```---
- name: restart consul
  service:
    name: consul
    state: restarted
```
# tasks
Idem als bij nomad alleen dan met consul.
```---
- name: add repo
  command: yum-config-manager --add-repo=https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

- name: install consul
  yum:
    name: consul
    state: installed

- name: add consul script
  template:
    src: consul.sh.j2
    dest: /etc/consul.d/consul.hc1
    owner: "root"
    group: "root"
    mode: 0744

- name: enable service consul
  service:
    name: consul
    enabled: yes
  notify: restart consul

```
# templates
De template van de script is wel anders bij consul. We geven de standaard variable mee zoals bind_addr en data_dir. We geven ook aan dat de ui true is. Ook controleer ik met een if of het een server is. Als dit true is zeg ik dat het een server is en krijgt hij de variable bootstrap_expect die op 1 staat. Als het geen server is geef ik de retry_join mee.
```#!/bin/bash
# {{ ansible_managed }}

bind_addr = {{ ansible_eth1.ipv4.address }}
data_dir = "/opt/consul"
client_addr = "0.0.0.0"
ui = true

{% if ansible_hostname == 'SERVER' %}
    server = true
    bootstrap_expect = 1
{% else %}
    retry_join = ["192.168.1.2"]
{% endif %}
```
# Docker
# handlers
Idem zoals bij nomad. Alleen met de docker-service
```---
- name: restart docker
  service:
    name: docker
    state: restarted
```
# tasks
Ik voeg eerst de hashicorp repo mee. Dan installeer ik 3 onderstaande services zodat docker werkt. ook enable ik docker door bovenstaande handler te gebruiken.
```---
- name: add repo
  command: yum-config-manager --add-repo=https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

- name: install docker-ce
  yum:
    name: docker-ce
    state: installed

- name: install docker-ce-cli
  yum:
    name: docker-ce-cli
    state: installed

  - name: install container.io
  yum:
    name: container.io
    state: installed

- name: enable service docker
  service:
    name: docker
    enabled: yes
  notify: restart docker
```
# Gebruikte bronnen
- Slides lessen
- https://www.vagrantup.com/docs/provisioning/ansible_local
- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html
- https://www.vagrantup.com/docs/provisioning/ansible_common
- https://docs.ansible.com/ansible/latest/scenario_guides/guide_vagrant.html
