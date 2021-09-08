#!/usr/bin/env bash

set -e

if [ "$EUID" -eq 0 ]; then
    echo "Please don't run as root."
    exit 1
fi

usage() {
    cat <<'EOF'
Usage:
  setup.sh --wallet-address <your crypto wallet address>
  or
  setup.sh -w <your crypto wallet address>
  setup.sh --help
EOF
}

check_wallet_is_specified() {
    if [ -z "$WALLET_ADDRESS" ]; then
        echo "Error: you must specify the wallet address."
        usage
        exit 1
    fi
}

# We don't use getopt because we want to support running micro-pkc on macOS.
# macOS has getopt, but it doesn't have `long` option
# See https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            usage
            exit 0
            ;;
        -w|--wallet-address)
            WALLET_ADDRESS="$2"
            check_wallet_is_specified
            shift
            shift
            ;;
        *)    # unknown option
            usage
            exit 0
            ;;
    esac
done

check_wallet_is_specified

# https://ethereum.stackexchange.com/questions/1374/how-can-i-check-if-an-ethereum-address-is-valid
# TODO make this address validation more comprehensive.
if [[ ! "$WALLET_ADDRESS" =~ ^(0x)?[0-9a-fA-F]{40}$ ]]; then
    echo "Error: Your wallet address is not a valid Ethereum address."
    exit 1
fi

# Convert wallet address to lower case
# This is because the address returned in Metamask API is in lower case
WALLET_ADDRESS=${WALLET_ADDRESS,,}

# Check Docker installation
if [[ -x "$(command -v docker)" ]]; then
    true
else
    echo "Docker is not yet installed. Aborting PKC installation."
    exit 1
fi

# Check docker-compose installation
if [[ -x "$(command -v docker-compose)" ]]; then
    true
else
    echo "docker-compose is not yet installed. Aborting PKC installation."
    exit 1
fi

# Check git installation
if [[ -x "$(command -v git)" ]]; then
    true
else
    echo "Git is not yet installed. Aborting PKC installation."
    exit 1
fi

mkdir -p mountPoint/extensions

if [ ! -d ../DataAccounting ]; then
    echo "DataAccounting repo doesn't exist. Downloading..."
    # We need to do this line in a subshell so that the current directory is
    # not modified.
    (cd .. && git clone https://github.com/FantasticoFox/DataAccounting.git)
else
    echo "DataAccounting repo exists. But you may want to update it after this setup."
fi

PARENTDIR="$(dirname "$PWD")"
DEST=mountPoint/extensions/DataAccounting
if [[ -L "$DEST" && -d "$DEST" ]]; then
    true
else
    echo "Making a symlink for the DataAccounting repo..."
    SOURCE="$PARENTDIR/DataAccounting"
    echo "Source: $SOURCE"
    ln -sf "$SOURCE" "$DEST"
fi

echo "Executing docker-compose up -d. Be prepared to type your password."
sudo docker-compose up -d
# Sleep; just to be sure that the container has initialized well.
sleep 10

# Restarting the Eauth server so that it can finally have access to the DB.
sudo docker exec -it micro-pkc_eauth_1 pkill node

echo "Installing MediaWiki"
sudo docker exec -it micro-pkc_mediawiki_1 ./aqua/install_pkc.sh "$WALLET_ADDRESS"

echo "Setting up Eauth Server (Ethereum single sign-on)"
sudo docker exec -it micro-pkc_eauth_1 npx sequelize-cli db:seed:all

echo "Done!"
