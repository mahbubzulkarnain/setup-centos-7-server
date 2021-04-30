#!/bin/sh

echo "install rancher..."
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker
sudo yum install iscsi-initiator-utils -y
sudo tee -a /etc/sysctl.d/99-kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system
sudo docker run -d --privileged --restart=unless-stopped -p 80:80 -p 443:443 -v /opt/rancher:/var/lib/rancher --name=rancher rancher/rancher:stable
