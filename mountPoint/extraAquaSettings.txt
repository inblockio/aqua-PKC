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
