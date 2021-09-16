# Taken from https://www.schemecolor.com/spurious.php
# Celadon Blue
$wgMedikColor = "#0582AD";

# Default width for the PDF object container.
$wgPdfEmbed['width'] = 800;

# Default height for the PDF object container.
$wgPdfEmbed['height'] = 1090;

# Allow user the usage of the pdf tag
$wgGroupPermissions['*']['embed_pdf'] = true;

$wgShowExceptionDetails = true;

# remove login and logout buttons for all users
function StripLogin(&$personal_urls, &$wgTitle) {
    unset( $personal_urls["login"] );
    # unset( $personal_urls["logout"] );
    unset( $personal_urls['anonlogin'] );
    return true;
}

# Disable StripLogin for now
# $wgHooks['PersonalUrls'][] = 'StripLogin';

# Disable reading by anonymous users
# WARNING: If you uncomment this line, remote verification via API will be
# denied access.
# $wgGroupPermissions['*']['read'] = false;

# Disable anonymous editing
$wgGroupPermissions['*']['edit'] = false;

# Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;

// TODO generate a better secret
$wgOAuth2Client['client']['id']     = 'pkc'; // The client ID assigned to you by the provider
$wgOAuth2Client['client']['secret'] = 'pkc'; // The client secret assigned to you by the provider

$EAUTH_PORT = 'EAUTH_PORT_PLACEHOLDER';
$wgOAuth2Client['configuration']['authorize_endpoint']     = "http://localhost:$EAUTH_PORT/oauth/authorize"; // Authorization URL
$wgOAuth2Client['configuration']['access_token_endpoint']  = "http://eauth:$EAUTH_PORT/oauth/token"; // Token URL
$wgOAuth2Client['configuration']['api_endpoint']           = "http://eauth:$EAUTH_PORT/oauth/user"; // URL to fetch user JSON
$wgOAuth2Client['configuration']['redirect_uri']           = 'http://localhost:9352/index.php/Special:OAuth2Client/callback'; // URL for OAuth2 server to redirect to

$wgOAuth2Client['configuration']['username'] = 'address'; // JSON path to username
$wgOAuth2Client['configuration']['email'] = 'email'; // JSON path to email

$wgOAuth2Client['configuration']['scopes'] = 'openid email profile'; //Permissions
$wgOAuth2Client['configuration']['service_login_link_text'] = 'Login with Ethereum wallet'; // the text of the login link
$wgWhitelistRead = ['Special:OAuth2Client', 'Special:OAuth2Client/redirect'];
