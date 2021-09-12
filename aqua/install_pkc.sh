#!/usr/bin/env bash

set -ex

WALLET_ADDRESS="$1"

BASE_EXTENSIONS="CategoryTree,Cite,CiteThisPage,ConfirmEdit,EmbedVideo,Gadgets,ImageMap,InputBox,Interwiki,LocalisationUpdate,MultimediaViewer,Nuke,OATHAuth,PageImages,ParserFunctions,PDFEmbed,PdfHandler,Poem,Renameuser,ReplaceText,Scribunto,SecureLinkFixer,SpamBlacklist,SyntaxHighlight_GeSHi,TemplateData,TextExtracts,TitleBlacklist,WikiEditor"
EXTENSIONS="$BASE_EXTENSIONS,PDFEmbed,DataAccounting,MW-OAuth2Client"

admin_password="$(openssl rand -base64 20)"

echo "Your admin password is $admin_password"

# TODO install intersection extension
# --quiet
# --wiki=domain_id
# Use --dbpassfile and --passfile for higher security
php maintenance/install.php --server="http://localhost:9352" \
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

# Extend settings
cat aqua/extraAquaSettings.php >> LocalSettings.php

# Disable VisualEditor
sed -i "s/wfLoadExtension( 'VisualEditor' );/#wfLoadExtension( 'VisualEditor' );/" LocalSettings.php

# Update sidebar
php maintenance/edit.php -s "Use PKC sidebar" -u Admin MediaWiki:Sidebar < aqua/sidebar.wiki

# Populate a page
php maintenance/edit.php -a -u Admin "Moores Law" < aqua/MooresLaw.wiki

# Ensure the config file can be written from the backend
chown www-data:www-data /var/www/html/data_accounting_config.json

