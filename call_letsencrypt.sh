#! /bin/bash -e


#   H E Y,   Y O U !    C H A N G E    T H E S E   S E T T I N G S !
email=
executable=/root/letsencrypt/letsencrypt-auto
# ==================================================================


function usage() {
	echo ""
	echo "Usage: call_letsencrypt.sh [-h] [-a] [-d] [-p] <main_domain> [<secondary_domain>...]"
	echo ""
	echo "Adds or renews SSL / TLS certificates from Let's Encrypt"
	echo "using their 'webroot' plugin."
	echo "Then calls chmod 400 on the domain's certificate and key files."
	echo "Finally, reloads the services specified by the arguments:"
	echo "  -a = Apache"
	echo "  -d = Dovecot"
	echo "  -p = Postfix"
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


reload_apache=0
reload_dovecot=0
reload_postfix=0

while getopts "hadp" OPTION ; do
	case $OPTION in
		a)
			reload_apache=1
			;;
		d)
			reload_dovecot=1
			;;
		p)
			reload_postfix=1
			;;
		h|?)
			usage
			exit
			;;
	esac
done


if [[ -z "$email" ]] ; then
	error "Edit this script's \"email\" setting before use" 2
fi

if [[ ! -x "$executable" ]] ; then
	error "Edit this script's \"executable\" setting before use" 3
fi


i=0
main_domain=
document_root=
domains_args=

for domain in "$@" ; do
	i=$[i + 1]
	if [ $i -lt $OPTIND ] ; then
		continue
	fi

	if [ -z "$main_domain" ] ; then
		main_domain="$domain"
		document_root="/var/www/$domain/public_html"
		domain_args+=" -w '$document_root'"
	fi
	domain_args+=" -d '$domain'"
done

if [[ -z "$main_domain" ]] ; then
	error "The <main_domain> parameter is required" 0
	usage
	exit 1
fi

if [[ ! -w "$document_root" ]] ; then
	error "Web root directory is not writable: '$document_root'" 4
fi


$executable certonly --webroot \
	--renew-by-default --agree-tos --email "$email" $domain_args

find "/etc/letsencrypt/archive/$main_domain" -type f -exec chmod 400 {} \;

if [ $reload_apache -eq 1 ] ; then
	service apache2 reload
fi

if [ $reload_dovecot -eq 1 ] ; then
	service dovecot reload
fi

if [ $reload_postfix -eq 1 ] ; then
	service postfix reload
fi
