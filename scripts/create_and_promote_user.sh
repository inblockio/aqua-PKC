#!/usr/bin/env bash

set -e

usage() {
    cat <<'EOF'
Usage:
  create_and_promote_user.sh [--sysop] -u username [-p password]

Create a new user or modifies an existing user for the PKC MediaWiki.

Options:
  --sysop  Turn the user into an admin
  -u       Username
  -p       Password
EOF
}

if [ $# -eq 0 ]; then
    # If no argument is provided, provide info and exit early.
    usage
    exit 0
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -h|--help)
        usage
        exit 0
        ;;
      --sysop)
        SYSOP=--sysop
        shift
        ;;
      -u)
        USERNAME="$2"
        shift
        shift
        ;;
      -p)
        PASSWORD="$2"
        shift
        shift
        ;;
      *)    # unknown option
        usage
        exit 1
        ;;
    esac
done
if [ -z "$USERNAME" ]; then
  echo "Error: '-u <username>' is a required argument."
  exit 1
fi

if [ -z "$PASSWORD" ]; then
  PASSWORD="$(openssl rand -base64 20)"
  echo "No password specified. So we auto-generated one for you: $PASSWORD"
fi

sudo docker exec micro-pkc-mediawiki php maintenance/createAndPromote.php $SYSOP "$USERNAME" "$PASSWORD" --force
