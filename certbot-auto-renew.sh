#!/bin/sh

0 0 * * 1 /usr/bin/certbot renew >> /var/log/sslrenew.log
