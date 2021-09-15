#!/usr/bin/env bash

MW_DIR=/var/www/html
if [ -f /backup/LocalSettings.php ]; then
    if [ ! -L $MW_DIR/LocalSettings.php ]; then
        ln -s /backup/LocalSettings.php $MW_DIR/LocalSettings.php
    fi
fi

if [ -f /backup/data_accounting_config.json ]; then
    if [ ! -L $MW_DIR/data_accounting_config.json ]; then
        ln -s /backup/data_accounting_config.json $MW_DIR/data_accounting_config.json
    fi
fi

# This is the original MediaWiki entrypoint
apache2-foreground
