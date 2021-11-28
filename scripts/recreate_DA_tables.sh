#!/usr/bin/env bash

# Drop all tables created by the Data accounting extension.
docker exec -it micro-pkc-database mysql -u wikiuser -p my_wiki --execute="DROP TABLE IF EXISTS revision_verification,witness_events,witness_page,witness_merkle_tree;"
docker exec micro-pkc-mediawiki php /var/www/html/maintenance/update.php
