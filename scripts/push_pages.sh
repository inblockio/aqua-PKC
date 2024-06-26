#!/bin/bash

server="http://localhost:9352"
apiUrl="$server/rest.php/data_accounting"

function pushHashChainJson {
    filename="$1"
    fileContent=$(cat "$filename")
    pages=$(echo "$fileContent" | jq '.pages')

    # Get length of the pages array
    len=$(echo "$pages" | jq '. | length')

    # Iterate through pages
    for (( i=0; i<$len; i++ )); do
        page=$(echo "$pages" | jq ".[$i]")
        site_info=$(echo "$fileContent" | jq '.site_info')

        # Construct context object
        context=$(echo "$page" | jq "{
            genesis_hash: .genesis_hash,
            domain_id: .domain_id,
            latest_verification_hash: .latest_verification_hash,
            title: .title,
            namespace: .namespace,
            chain_height: .chain_height,
            site_info: $site_info
        }")

        revisions=$(echo "$page" | jq '.revisions')

        # Loop through each key-value pair in revisions
        for verificationHash in $(echo "${revisions}" | jq 'keys | .[]'); do
            revision=$(echo "${revisions}" | jq ".[$verificationHash]")
            echo "Pushing $verificationHash"

            # Construct payload
            payload=$(jq -n --argjson context "$context" --argjson revision "$revision" '{
                context: $context,
                revision: $revision
            }')

            # Perform POST request
            response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" --data "$payload" "$apiUrl/import")
            #commenting out to write to file response=$(curl -s -o response.txt -w "%{http_code}" -X POST -H "Content-Type: application/json" --data "$payload" "$apiUrl/import")
            if [[ "$response" != "200" ]]; then
                echo "/import failed"
                #cat response.txt | jq .
                exit 1
            fi
        done
    done
}

# Main loop over JSON files in directory
folderPath="import"
for filename in "$folderPath"/*.json; do
    if [[ -f "$filename" ]]; then
        echo "Processing $filename"
        pushHashChainJson "$filename"
    else
        echo "$filename is not a JSON file, hence skipping."
    fi
done

