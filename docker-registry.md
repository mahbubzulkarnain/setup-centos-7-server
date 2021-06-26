# install docker

```
sudo useradd me
sudo passwd me

sudo tee -a /etc/sudoers.d/me <<EOF
me  ALL=(ALL:ALL) NOPASSWD: ALL
EOF

su me 
cd ~

sudo curl -o /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo 
sudo yum -y install docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable --now docker
```

# install docker-compose

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

# install letsencrypt

```
sudo yum -y install epel-release
sudo yum -y install certbot

export DOMAIN="registry.domain.com"
export EMAIL="email@domain.com"
sudo certbot certonly --standalone -d $DOMAIN --preferred-challenges http --agree-tos -n -m $EMAIL --keep-until-expiring
```

# path cert under /etc/letsencrypt/live/

/etc/letsencrypt/live/registry.domain.com/fullchain.pem /etc/letsencrypt/live/registry.domain.com/privkey.pem notes:

- fullchain.pem = combined file cert.pem and chain.pem
- chain.pem = intermediate certificate
- cert.pem ⇒ SSL Server cert(includes public-key)
- privkey.pem ⇒ private-key file

```
sudo mkdir /var/lib/docker/registry

sudo mkdir /certs
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /certs/fullchain.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /certs/privkey.pem
sudo cp /etc/letsencrypt/live/$DOMAIN/cert.pem /certs/cert.pem

cat << EOF > ~/docker-compose.yml
version: '3'
services:
  docker-registry:
    image: registry:2
    volumes:
      - "/certs:/certs"
      - "/var/lib/docker/registry:/var/lib/registry"
    ports:
      - "5000:5000"
    restart: always
    environment:
      - REGISTRY_HTTP_ADDR=0.0.0.0:5000
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.pem
      - REGISTRY_HTTP_TLS_KEY=/certs/privkey.pem
  docker-registry-ui:
    image: parabuzzle/craneoperator:latest
    ports:
      - "8086:80"
    environment:
      - REGISTRY_HOST=docker-registry
      - REGISTRY_PORT=5000
      - REGISTRY_PROTOCOL=https
      - REGISTRY_ALLOW_DELETE=true
      - SSL_VERIFY=false
      - USERNAME=root
      - PASSWORD=mypassword
    restart: always
    depends_on:
      - docker-registry
EOF

docker-compose up -d

sudo yum -y install firewalld
sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --add-port=5000/tcp --permanent
sudo firewall-cmd --add-port=8086/tcp --permanent
sudo firewall-cmd --reload

```

# setup insecure Registry setting

For CentOS 7, edit the file /etc/docker/daemon.json

```
sudo tee -a /etc/docker/daemon.json <<EOF
{
  "insecure-registries": [
    "registry.domain.com:5000"
  ]
}
EOF

sudo systemctl restart docker
```

# list images

https://domain.example.com:5000/v2/_catalog