#!/usr/bin/env bash

# This is a wrapper around MediaWiki_Backup's backup.sh
/MediaWiki_Backup/backup.sh \
    -p "$(date -u +"%Y-%m-%dT%H-%M-%S_UTC")" -d /backup -w /var/www/html -s -f
# Clean up all backup files except for the most recent 5.
# https://stackoverflow.com/questions/25785/delete-all-but-the-most-recent-x-files-in-bash
# shellcheck disable=SC2012
(cd /backup && ls -tp ./*.tar.gz | tail -n +6 | xargs -d '\n' -r rm --)
