#!/usr/bin/env bash

set -e

generate_random_string() {
	echo "$(echo $RANDOM | md5sum | head -c 20)"
}

WALLET_ADDRESS="0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefde"
page_title="Main Page"
echo "Adding 50 more revisions to $page_title"
page_content=$(docker exec micro-pkc-mediawiki php maintenance/getText.php "$page_title")
for ((i = 1; i <= 50; i++)); do
	echo "Step $i"
	page_content="$page_content $i; randomly generated content: $(generate_random_string)<br>"
	echo "$page_content" | docker exec -i micro-pkc-mediawiki php maintenance/edit.php -a -u "$WALLET_ADDRESS" "$page_title"
done
