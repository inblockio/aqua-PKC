#!/usr/bin/env bash

MW_DIR=/var/www/html
if [ -f /backup/LocalSettings.php ]; then
    if [ ! -L $MW_DIR/LocalSettings.php ]; then
       echo -e '<?php\nrequire_once "/backup/LocalSettings.php";' > $MW_DIR/LocalSettings.php
    fi
fi

# This is the original MediaWiki entrypoint
# TODO watch https://github.com/wikimedia/mediawiki-docker. They might change
# the entrypoint detail at some point in the future!
apache2-foreground
