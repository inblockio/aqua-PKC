#!/usr/bin/env bash

set -e

mkdir -p mountPoint/extensions

if [ ! -d ../DataAccounting ]; then
    echo "DataAccounting repo doesn't exist. Downloading..."
    # We need to do this line in a subshell so that the current directory is
    # not modified.
    (cd .. && git clone https://github.com/FantasticoFox/DataAccounting.git)
fi

PARENTDIR="$(dirname "$PWD")"
echo "Making a symlink for the DataAccounting repo..."
SOURCE="$PARENTDIR/DataAccounting"
echo "Source: $SOURCE"
ln -sf "$SOURCE" mountPoint/extensions/DataAccounting

echo "Executing docker-compose up -d. Be prepared to type your password."
sudo docker-compose up -d
# Sleep; just to be sure that the container has initialized well.
sleep 3

echo "Installing MediaWiki"
sudo docker exec -it micro-pkc_mediawiki_1 ./aqua/install_pkc.sh

echo "Done!"
