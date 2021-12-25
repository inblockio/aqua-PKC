#!/usr/bin/env bash

set -e

docker exec micro-pkc-mediawiki sed -i '7 i	AddOutputFilterByType DEFLATE application/json' /etc/apache2/mods-enabled/deflate.conf
docker-compose restart mediawiki
