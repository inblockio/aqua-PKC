#!/usr/bin/env bash

set -e

WALLET_ADDRESS="$1"
if [ -z "$WALLET_ADDRESS" ]; then
    echo "Error: you must specify the wallet address."
    exit 1
fi

json=$(curl 'http://localhost:9352/api.php?action=query&format=json&list=allpages')
echo "$json" | jq -c '.query.allpages[]' | while read -r each; do
    page_title=$(echo "$each" | jq -c -r '.title')
    echo "$page_title"
    if [[ "$page_title" == "File:"* ]]; then
        echo "This page is a file page, hence skipped."
        continue
    fi
    page_content=$(docker exec micro-pkc-mediawiki php maintenance/getText.php "$page_title")

    # Delete the page
    docker exec micro-pkc-mediawiki bash -c "echo '$page_title' > temp_delete_me.txt"
    docker exec micro-pkc-mediawiki php maintenance/deleteBatch.php temp_delete_me.txt

    # Create the page
	echo "$page_content" | docker exec -i micro-pkc-mediawiki php maintenance/edit.php -a -u "$WALLET_ADDRESS" "$page_title"
    echo "Done!"
done
