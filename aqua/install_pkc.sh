#!/usr/bin/env bash

set -e

while [ "$#" -gt 0 ]; do
    case "$1" in
        -w|--wallet-address)
            WALLET_ADDRESS="$2"
            shift
            shift
            ;;
        -s|--pkc-server)
            PKC_SERVER="$2"
            shift
            shift
            ;;
        --eauth-server)
            EAUTH_SERVER="$2"
            shift
            shift
            ;;
        --empty-wiki)
            empty_wiki=true
            shift
            ;;
        --private)
            private=true
            shift
            ;;
        *)    # unknown option
            echo "Unknown flag option, exiting"
            exit 0
            ;;
    esac
done


BASE_EXTENSIONS="CategoryTree,Cite,CiteThisPage,ConfirmEdit,EmbedVideo,Gadgets,ImageMap,InputBox,Interwiki,LocalisationUpdate,MultimediaViewer,Nuke,OATHAuth,PageImages,ParserFunctions,PDFEmbed,PdfHandler,Poem,Renameuser,ReplaceText,Scribunto,SecureLinkFixer,SpamBlacklist,SyntaxHighlight_GeSHi,TemplateData,TextExtracts,TitleBlacklist,WikiEditor"
EXTENSIONS="$BASE_EXTENSIONS,PDFEmbed,DataAccounting,MW-OAuth2Client"

admin_password="$(openssl rand -base64 20)"

echo "Your admin password is $admin_password"

# If LocalSettings.php exists, exit early
if [ -f LocalSettings.php ]; then
    echo "A LocalSettings.php file has been detected."
    echo "Exiting early"
    exit 1
fi

install_media_wiki(){

    echo "Installing MediaWiki"
    # TODO install intersection extension
    # --quiet
    # --wiki=domain_id
    # Use --dbpassfile and --passfile for higher security
    php maintenance/install.php --server="$PKC_SERVER" \
                    --dbuser=wikiuser \
                    --dbpass=example \
                    --dbname=my_wiki \
                    --dbserver="database" \
                    --pass="$admin_password" \
                    --skins=Medik \
                    --with-extensions="$EXTENSIONS" \
                    --scriptpath="" \
                    "Personal Knowledge Container" \
                    "$WALLET_ADDRESS"
    
}

retry_counter=0
while ! install_media_wiki; do
    if [ $retry_counter -gt 4 ]; then
        echo "MediaWiki intallation retries exceeded"
        break
    fi
    retry_counter=$((retry_counter+1))
    echo "Retrying MediaWiki installation"
    sleep 5
done

# Extend settings
cat aqua/extraAquaSettings.php >> LocalSettings.php

# Disable anonymous read for private wiki
if [ "$private" = true ]; then
    sed -i "s|wgGroupPermissions\['\*'\]\['read'\] = true;|wgGroupPermissions['*']['read'] = false;|"  LocalSettings.php
fi

# Specify PKC_SERVER
sed -i "s|PKC_SERVER|$PKC_SERVER|" LocalSettings.php

# Specify Eauth port
sed -i "s/EAUTH_PORT_PLACEHOLDER/$PORT/" LocalSettings.php

# Put in Eauth server if specified
if [ -n "$EAUTH_SERVER" ]; then
sed -i "s|eauthServer = .*|eauthServer = '$EAUTH_SERVER';|" LocalSettings.php
fi

# Disable VisualEditor
sed -i "s/wfLoadExtension( 'VisualEditor' );/#wfLoadExtension( 'VisualEditor' );/" LocalSettings.php

# Enable file upload
sed -i "s/wgEnableUploads = false;/wgEnableUploads = true;/" LocalSettings.php

# Insert domain ID to LocalSettings.php.
# The first openssl command is for entropy source. The second openssl command
# is for doing a sha3sum. The xxd command converts the sha sum in binary to hex
# format. And finally the head commands returns only the first 10 characters.
DOMAIN_ID=$(openssl rand -hex 64 | openssl dgst -sha3-512 -binary | xxd -p -c 256 | head -c 10)
echo "\$wgDADomainID = '$DOMAIN_ID';" >> LocalSettings.php

# Insert smart contract address to LocalSettings.php.
echo "\$wgDASmartContractAddress = '0x45f59310ADD88E6d23ca58A0Fa7A55BEE6d2a611';" >> LocalSettings.php

# Insert witness network to LocalSettings.php
cat <<EOF >> LocalSettings.php
# Possible values are:
# - mainnet
# - goerli
# - See more at https://besu.hyperledger.org/en/stable/Concepts/NetworkID-And-ChainID/
\$wgDAWitnessNetwork = 'goerli';
EOF

# Insert signature injection configuration to LocalSettings.php
echo "\$wgDAInjectSignature = true;" >> LocalSettings.php

# Set required permissions to store images
chown -R www-data:www-data /var/www/html/images

# Update sidebar
php maintenance/edit.php -s "Use PKC sidebar" -u "$WALLET_ADDRESS" MediaWiki:Sidebar < aqua/sidebar.wiki

# Update login required text
echo "Please [[Special:OAuth2Client/redirect|log in with Ethereum]] to view other pages." | php maintenance/edit.php -s "Use PKC login required text" -u "$WALLET_ADDRESS" MediaWiki:Loginreqpagetext

# Populate default pages from /PKC-Content
extract_page_title() {
    basename "$1" .wiki
}
MW_DIR=/var/www/html
if [[ ! $empty_wiki ]]; then
    for file in "$MW_DIR"/aqua/PKC-Content/*.wiki; do
        echo "Populating $file into wiki"
        php maintenance/edit.php -a -u "$WALLET_ADDRESS" "$( extract_page_title "$file" )" < "$file"
    done
fi

# Move the actual LocalSettings.php file to a backup folder that persists after a
# docker-compose down.
mv $MW_DIR/LocalSettings.php /backup/LocalSettings.php
ln -s /backup/LocalSettings.php $MW_DIR/LocalSettings.php
