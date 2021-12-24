#!/usr/bin/env bash

# shellcheck disable=SC2089
content="\$wgDebugLogFile = \"/var/www/html/pkc_log.txt\";"
sudo docker exec micro-pkc-mediawiki bash -c "echo '$content' >> /var/www/html/LocalSettings.php"
