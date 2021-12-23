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

# Modify the default Login button to become OAuth2 login.
function ModifyDefaultLogin(&$personal_urls, &$wgTitle) {
	$keys = ["login", "anonlogin", "login-private"];
	foreach ($keys as $key) {
		if (array_key_exists($key, $personal_urls)) {
			$old_url_arr = explode("&", $personal_urls[$key]["href"]);
			$params = "";
			if (count($old_url_arr) > 1) {
				// Add URL params only when they exist.
				$params = "&" . $old_url_arr[1];
			}
			$personal_urls[$key]["href"] = "/index.php?title=Special:OAuth2Client/redirect" . $params;
		}
	}

	return true;
}

$wgHooks['PersonalUrls'][] = 'ModifyDefaultLogin';

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
$EAUTH_PORT = 'EAUTH_PORT_PLACEHOLDER';
$pkcServer = 'PKC_SERVER';
$parsedPkcServer = parse_url($pkcServer);
$pkcHost = $parsedPkcServer['scheme'] . '://' . $parsedPkcServer['host'];
$eauthServer = "$pkcHost:$EAUTH_PORT";
# TODO generate a better secret
$wgOAuth2Client['client']['id']     = 'pkc';  # The client ID assigned to you by the provider
$wgOAuth2Client['client']['secret'] = 'pkc';  # The client secret assigned to you by the provider
$wgOAuth2Client['configuration']['authorize_endpoint']     = "$eauthServer/oauth/authorize"; // Authorization URL
$wgOAuth2Client['configuration']['access_token_endpoint']  = "http://eauth:$EAUTH_PORT/oauth/token"; // Token URL
$wgOAuth2Client['configuration']['api_endpoint']           = "http://eauth:$EAUTH_PORT/oauth/user"; // URL to fetch user JSON
$wgOAuth2Client['configuration']['redirect_uri']           = "$pkcServer/index.php/Special:OAuth2Client/callback"; // URL for OAuth2 server to redirect to

$wgOAuth2Client['configuration']['username'] = 'address'; // JSON path to username
$wgOAuth2Client['configuration']['email'] = 'email'; // JSON path to email

$wgOAuth2Client['configuration']['scopes'] = 'openid email profile'; //Permissions
$wgOAuth2Client['configuration']['service_login_link_text'] = 'Login with Ethereum wallet'; // the text of the login link
$wgWhitelistRead = ['Main Page', 'Special:OAuth2Client', 'Special:OAuth2Client/redirect'];
# We need a trailing newline below so that the resulting LocalSettings.php looks nice. Don't delete!

# Deactivate Visual Editor as it does not work on localhost currently.
# Visual Editor
# $wgDefaultUserOptions['visualeditor-enable'] = 1;
# Optional: Enable VisualEditor's experimental code features
# $wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;

$wgDefaultUserOptions['visualeditor-autodisable'] = true;
$wgDefaultUserOptions['visualeditor-newwikitext'] = 1;
