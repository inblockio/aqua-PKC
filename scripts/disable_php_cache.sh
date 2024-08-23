#!/usr/bin/env bash
sudo docker exec micro-pkc-mediawiki sed -i 's/;opcache.enable=1/opcache.enable=0/' /usr/local/etc/php/php.ini
sudo docker compose restart mediawiki
