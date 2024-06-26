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
        --siweoidc-server)
            SIWEOIDC_SERVER="$2"
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

# Extensions removed:
# - ConfirmEdit, because unnecessary spam protection
# - EmbedVideo, because not working in MW 37
# - SpamBlacklist because unnecessary spam protection
BASE_EXTENSIONS="CategoryTree,Cite,CiteThisPage,Gadgets,ImageMap,InputBox,Interwiki,LocalisationUpdate,MultimediaViewer,Nuke,OATHAuth,PageImages,ParserFunctions,PDFEmbed,PdfHandler,Poem,Renameuser,ReplaceText,Scribunto,SecureLinkFixer,SyntaxHighlight_GeSHi,TemplateData,TextExtracts,TitleBlacklist,WikiEditor"
EXTENSIONS="$BASE_EXTENSIONS,PDFEmbed,DataAccounting,PluggableAuth,OpenIDConnect,PageForms"

admin_password="$(openssl rand -base64 20)"

echo "Your admin password is $admin_password"

# If LocalSettings.php exists, exit early
if [ -f LocalSettings.php ]; then
    echo "A LocalSettings.php file has been detected."
    echo "Exiting early"
    exit 1
fi

install_media_wiki(){

    echo "Running composer update"
    composer update --no-dev

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
                    --skins=Tweeki \
                    --with-extensions="$EXTENSIONS" \
                    --scriptpath="" \
                    "Personal Knowledge Container" \
                    "$WALLET_ADDRESS"

    php extensions/DataAccounting/maintenance/createSysopUser.php Guardian
    generate_guardian_token 32
    echo "Guardian security token is: $GUARDIAN_TOKEN"
}

generate_guardian_token() {
    local token_length=$1
    TOKEN=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c "$token_length")
    GUARDIAN_TOKEN=$(echo -n "$TOKEN" | base64)
}

echo "Running composer update"
composer update --no-dev
echo "Applying patches"
./apply-patches.sh

retry_counter=0
while ! install_media_wiki; do
    if [ $retry_counter -gt 4 ]; then
        echo "MediaWiki installation retries exceeded"
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

# Put in SIWE server if specified
if [ -n "$SIWEOIDC_SERVER" ]; then
sed -i "s|siweServer = .*|siweServer = '$SIWEOIDC_SERVER';|" LocalSettings.php
fi

disable_extension() {
    local name="$1"
    sed -i "s/wfLoadExtension( '$name' );/#wfLoadExtension( '$name' );/" LocalSettings.php
}

# Insert guardian token to LocalSettings.php
echo "Set guardian token in LocalSettings.php"
sed -i "\$ a \$daGuardianToken='${GUARDIAN_TOKEN}';" LocalSettings.php

#disable_extension VisualEditor
disable_extension ConfirmEdit
disable_extension SpamBlacklist
# Dependency issues in MW 1.39. Also, since PKC is not public, not needed
disable_extension AbuseFilter

# Enable file upload
sed -i "s/wgEnableUploads = false;/wgEnableUploads = true;/" LocalSettings.php

# Insert domain ID to LocalSettings.php.
# The first openssl command is for entropy source. The second openssl command
# is for doing a sha3sum. The xxd command converts the sha sum in binary to hex
# format. And finally the head commands returns only the first 10 characters.
# Commented out because now we generate the domain ID from inside the DataAccounting extension.
# DOMAIN_ID=$(openssl rand -hex 64 | openssl dgst -sha3-512 -binary | xxd -p -c 256 | head -c 10)
# echo "\$daDomainID = '$DOMAIN_ID';" >> LocalSettings.php

# Insert smart contract address to LocalSettings.php.
echo "\$daSmartContractAddress = '0x45f59310ADD88E6d23ca58A0Fa7A55BEE6d2a611';" >> LocalSettings.php
echo "\$daWalletAddress = '$WALLET_ADDRESS';" >> LocalSettings.php

# Insert witness network to LocalSettings.php
cat <<EOF >> LocalSettings.php
# Possible values are:
# - mainnet
# - sepolia
# - See more at https://besu.hyperledger.org/en/stable/Concepts/NetworkID-And-ChainID/
\$daWitnessNetwork = 'sepolia';
EOF

# Insert signature injection configuration to LocalSettings.php
echo "\$daInjectSignature = true;" >> LocalSettings.php

# Set required permissions to store images
chown -R www-data:www-data /var/www/html/images

# Update sidebar
php maintenance/edit.php -s "Use PKC sidebar" -u "$WALLET_ADDRESS" MediaWiki:Sidebar < aqua/sidebar.wiki

do_edit() {
    local page="$1"
    local content="$2"
    local message="$3"
    echo "$content" | php maintenance/edit.php -s "$message" -u "$WALLET_ADDRESS" "$page"
}

# Add original sidebar to Tweeki right sidebar
do_edit MediaWiki:Tweeki-sidebar-right 'EDIT-EXT,SIDEBAR,TOC' "Add original sidebar to Tweeki right sidebar"
# Specify custom Weeki navbar:
# - Change style to dark
do_edit MediaWiki:Tweeki-navbar-class 'navbar navbar-default navbar-fixed-top navbar-expand-lg fixed-top navbar-dark bg-dark' "Modify Tweeki navbar class"
# Customize Tweeki
# Modify right navbar:
# - Make sure search bar is in the middle
# - Make sure there is login button when not logged in
# - Add "new page" button
do_edit MediaWiki:Tweeki-navbar-right 'INBOX,NEWPAGE,SEARCH,PERSONAL,LOGIN,TOOLBOX' "Put search bar in the middle; show login"
# Modify login text
do_edit MediaWiki:Tweeki-login 'Wallet Login' "Replace Login / Create"

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
    # Import Aqua-Chains as JSON (The pages which should be imported must be stored in the ./import directory in the root folder)
    ../scripts/push_pages.sh
fi


# Move the actual LocalSettings.php file to a backup folder that persists after a
# docker compose down.
mv $MW_DIR/LocalSettings.php /backup/LocalSettings.php
# Symlinks dont seem to work
# ln -s /backup/LocalSettings.php $MW_DIR/LocalSettings.php
echo -e '<?php\nrequire_once "/backup/LocalSettings.php";' > $MW_DIR/LocalSettings.php
