#!/bin/bash

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
