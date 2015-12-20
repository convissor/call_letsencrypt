#! /bin/bash -e


#   H E Y,   Y O U !    C H A N G E    T H E S E   S E T T I N G S !
email=
executable=/root/letsencrypt/letsencrypt-auto
# ==================================================================


function usage() {
	echo ""
	echo "Usage: call_letsencrypt.sh <main_domain> [<secondary_domain>...]"
	echo ""
	echo "Adds or renews SSL / TLS certificates from Let's Encrypt"
	echo "using their 'webroot' plugin.  Then calls chmod 400 on the"
	echo "domain's certificate and key files."
	echo ""
	echo "NOTE:  If your website root directory is not"
	echo "    /var/www/<main_domain>/public_html"
	echo "you need to edit this script before using it."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "https://github.com/convissor/call_letsencrypt"
	echo ""
}

function error() {
	echo "ERROR: $1" >&2

	if [ "$2" -ne 0 ] ; then
		exit $2
	fi
}


if [[ "$1" == '-h' || "$1" == '--help' ]] ; then
	usage
	exit
fi

if [[ -z "$1" ]] ; then
	error "The <main_domain> parameter is required" 0
	usage
	exit 1
fi

if [[ -z "$email" ]] ; then
	error "Edit this script's \"email\" and \"executable\" settings before use" 0
	usage
	exit 2
fi


main_domain=
domains_args=

for domain in "$@" ; do
	if [ -z "$main_domain" ] ; then
		main_domain="$domain"
		domain_args+=" -w '/var/www/$domain/public_html'"
	fi
	domain_args+=" -d '$domain'"
done

$executable certonly --webroot \
	--renew-by-default --agree-tos --email "$email" $domain_args

find "/etc/letsencrypt/archive/$main_domain" -type f -exec chmod 400 {} \;
