#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run with sudo."
  exit 1
fi

# Define the hostname
HOSTNAME="siwe-oidc"

# Remove the entry from /etc/hosts
sudo sed -i "/$HOSTNAME/d" /etc/hosts
echo "Removed $HOSTNAME entry from /etc/hosts."

