#!/usr/bin/env bash

WALLET_ADDRESS="0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefde"
page_title="Main Page"
echo "Adding 50 more revisions to $page_title"
page_content=$(docker exec micro-pkc-mediawiki php maintenance/getText.php "$page_title")
for ((i = 1; i <= 50; i++)); do
	echo "Step $i"
	echo "$page_content $i" | docker exec -i micro-pkc-mediawiki php maintenance/edit.php -a -u "$WALLET_ADDRESS" "$page_title"
done
