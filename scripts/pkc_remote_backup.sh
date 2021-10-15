#!/usr/bin/env bash
# TODO check if rsync is install, add a usage help
# input is --server remote server with PKC if no local path is specified store ./ in current directory.
set -ex

server=$1

# check server variable
if [ -z "$server" ]; then
    echo "Error: you must specify the server address."
    exit 1
fi

# access remote server
ssh ubuntu@"$server" 'bash -c "cd /home/ubuntu/micro-PKC && ./pkc backup"'

# pull backups from remote server
rsync -a --progress --stats ubuntu@"$server":/home/ubuntu/micro-PKC/mountPoint/backup/2021* ./"$server"/

