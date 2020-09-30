#!/bin/sh

echo "install rancher..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo yum install iscsi-initiator-utils -y
sudo docker run -d --restart=unless-stopped -p 8080:80 -p 8443:443 rancher/rancher:stable
