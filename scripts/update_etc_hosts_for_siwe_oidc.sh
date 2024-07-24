#!/usr/bin/env bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run with sudo."
  exit 1
fi

# Retrieve the IP address from the docker inspect command
IP_ADDRESS=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' aqua-pkc_siwe-oidc_1)

# Define the hostname
HOSTNAME="siwe-oidc"

# Check if the entry exists in the /etc/hosts
grep -q "$HOSTNAME" /etc/hosts

if [ $? -eq 0 ]; then
    # Entry exists, check if IP address is the same
    CURRENT_IP=$(grep "$HOSTNAME" /etc/hosts | awk '{print $1}')
    if [ "$CURRENT_IP" != "$IP_ADDRESS" ]; then
        # IP address is different, update the entry
        sudo sed -i "/$HOSTNAME/c\\$IP_ADDRESS\t$HOSTNAME" /etc/hosts
        echo "Updated $HOSTNAME entry to IP $IP_ADDRESS in /etc/hosts."
    else
        echo "$HOSTNAME entry is already up to date."
    fi
else
    # Entry does not exist, add it
    echo "$IP_ADDRESS      $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
    echo "Added $HOSTNAME entry with IP $IP_ADDRESS to /etc/hosts."
fi

