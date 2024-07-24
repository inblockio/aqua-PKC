#!/usr/bin/env bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script needs to be run with sudo."
  exit 1
fi

# Place your script commands here
echo "Running with sufficient privileges."

# Define the path to the file relative to the script location
FILE_PATH="../mountPoint/backup/LocalSettings.php"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: $FILE_PATH does not exist."
    exit 1
fi

# Use sed to modify the file in-place
sed -i "s/\$wgGroupPermissions\['\*'\]\['createaccount'\] = false;/\$wgGroupPermissions['*']['createaccount'] = true;/g" "$FILE_PATH"

echo "Modified $FILE_PATH to enable account creation."

