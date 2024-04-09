# Taken from https://www.schemecolor.com/spurious.php
# Celadon Blue
# We use Tweeki but keep this for future design.
# $wgMedikColor = "#0582AD";

# Tweeki Settings
$wgTweekiSkinUseBootstrap4 = true;
# This adds the drop down option for the MW-actions to the Edit-Button.
$wgTweekiSkinHideNonAdvanced = [ 'EDIT-EXT-special' => false ];

# Default width for the PDF object container.
$wgPdfEmbed['width'] = 800;

# Default height for the PDF object container.
$wgPdfEmbed['height'] = 1090;

# Allow user the usage of the pdf tag
$wgGroupPermissions['*']['embed_pdf'] = true;

$wgShowExceptionDetails = true;

# Disable reading by anonymous users using `./pkc setup --private -w WALLET_ADDRESS`
# WARNING: If false, remote verification via API will be denied access.
$wgGroupPermissions['*']['read'] = true;

# Disable anonymous editing
$wgGroupPermissions['*']['edit'] = false;

# Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;

# IMPORTANT: We currently fork MW-OAuth2-Client so that it doesn't auto-create new
# user when it doesn't exist yet. If you happen to enable user auto-create,
# expect that MediaWiki will append "1" to the username if the user already
# exists to prevent collision. This is not a problem when the username is e.g.
# "Szabo", which MW auto-creates to "Szabo1", but is a problem when the
# username is a long wallet address, which makes the -1 suffix harder to spot.
#
# The following params are used only for the OAuth2 client extension
# configuration.
$pkcServer = 'PKC_SERVER';
$parsedPkcServer = parse_url($pkcServer);
$pkcHost = $parsedPkcServer['scheme'] . '://' . $parsedPkcServer['host'];
$siweServer = "SIWE_SERVER_PLACEHOLDER";

# For OIDC
# TODO generate a better secret
$wgPluggableAuth_Config['Login with Ethereum'] = [
   'plugin' => 'OpenIDConnect',
   'data' => [
       'providerURL' => $siweServer,
       'clientID' => 'siwe',
       'clientsecret' => 'siweaqua',
       'preferred_username' => 'preferred_username',
       'scope' => [ 'openid', 'profile' ],
   ]
];

// Allow OIDC to create users
$GLOBALS['wgGroupPermissions']['*']['autocreateaccount'] = true;

$wgWhitelistRead = ['Aqua Demo', 'Main Page', 'Special:OAuth2Client', 'Special:OAuth2Client/redirect', 'Spezial:OAuth2Client', 'Spezial:OAuth2Client/redirect', 'Special:PluggableAuthLogin', 'Spezial:PluggableAuthLogin'];
# We need a trailing newline below so that the resulting LocalSettings.php looks nice. Don't delete!

# The following lines are added to override a legacy MW behavior.
# We want this so that all the transcluded content are properly hashed and
# controlled. Even in hosted environments those caches should stay disabled to
# ensure that files which are imported will be verified against the import
# instead of a potential available cache. See documentation:
# https://www.mediawiki.org/wiki/Manual:FAQ#How_do_I_completely_disable_caching?
$wgEnableParserCache = false; // deprecated method
$wgParserCacheType = CACHE_NONE;
$wgCachePages = false;

# Deactivate Visual Editor as it does not work on localhost currently.
# Visual Editor
 $wgDefaultUserOptions['visualeditor-enable'] = 1;
# Optional: Enable VisualEditor's experimental code features
# $wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

#$wgDefaultUserOptions['visualeditor-autodisable'] = true;
$wgDefaultUserOptions['visualeditor-newwikitext'] = 1;
wfLoadExtension( 'Parsoid', "$IP/vendor/wikimedia/parsoid/extension.json" );
$wgVirtualRestConfig['modules']['parsoid'] = array(
	'url' => 'http://localhost' . $wgScriptPath . '/rest.php',
);

# Add new file types to the existing list from DefaultSettings.php
$wgFileExtensions = array_merge( $wgFileExtensions, [
   # MS Document Formats
   'docx',
   'doc',
   'xlsx',
   'xls',
   'pptx',
   'ppt',
   # Open Document Formats
   'odt',
   'ods',
   'odp',
   'odg',
   # PDF
   'pdf',
   # Picture Formats
   'png',
   'gif',
   # Audio and Video Formats
   'mpp',
   'mp3',
   'mp4',
   'ogg',
   # Archives
   'zip',
   '7z',
   'tar.gz',
]
);
