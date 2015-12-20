# Call Let's Encrypt

A little shell script to simplify getting and renewing SSL / TLS certificates
via [Let's Encrypt's](https://letsencrypt.org/) "webroot" plugin.

Set the `email` and `executable` variables in the script before using it.

If your website root directory is not `/var/www/<domain>/public_html`
you'll need to edit that part of the script as well.

The script also provides the option to reload apache2, dovecot and postfix
via `service <name> reload`.  If your system uses other services, service
names or means to reload such services, please adjust the script accordingly.
