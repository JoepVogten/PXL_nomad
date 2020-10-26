#!/bin/bash

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
client_addr = ""0.0.0.0"
data_dir = "/opt/nomad/server"
ui = true
bootstrap_expect = 1
END

systemctl daemon-reload
systemctl restart nomad
systemctl restart consul
