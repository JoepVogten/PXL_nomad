#!/bin/bash

#NOMAD
#deleting the default systemd config file for nomad
sudo rm -f /etc/nomad.d/nomad.hcl

#making a directory for the data
sudo mkdir /opt/nomad/client1

#making a new one
cat << END >/etc/nomad.d/client1.hcl
name = "client1"
data_dir = "/opt/nomad/nomad"
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
END

#restarting all services
systemctl daemon-reload
systemctl restart nomad
systemctl restart consul
