#!/usr/bin/env bash

set -euo pipefail

docker exec micro-pkc-mediawiki sh -c 'COMPOSER=composer.local.json composer require --no-update professional-wiki/network:~1.3'
docker exec micro-pkc-mediawiki composer update professional-wiki/network --no-dev -o

docker exec micro-pkc-mediawiki sh -c "echo \"wfLoadExtension( 'Network' );\" >> /var/www/html/LocalSettings.php"
