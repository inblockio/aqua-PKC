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
