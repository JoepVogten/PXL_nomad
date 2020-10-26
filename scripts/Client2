#!/bin/bash

#NOMAD
#deleting the default systemd config file for nomad
sudo rm -f /etc/nomad.d/nomad.hcl

#making a directory for the data
sudo mkdir /opt/nomad/client2

#making a new one
cat << END >/etc/nomad.d/client2.hcl
name = "client2"
data_dir = "/opt/nomad/nomad"
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
