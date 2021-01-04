#!/bin/bash
SSL_HOSTNAME=${SSL_HOSTNAME:-tower}

DIR="/etc/nginx/ssl/"
mkdir -p $DIR

if [[ -f $DIR/invoiceninja.crt ]];then
	echo "Cert already generated"
	exit
fi

if [[ -n $SSL_KEY ]] && [[ -n $SSL_CERT ]];then
  echo "$SSL_KEY" > $DIR/invoiceninja.key
  echo "$SSL_CERT" > $DIR/invoiceninja.crt
  exit # don't continue if a cert was provided
fi

# Enable SSL and add certificate files to Nginx
sed -i -e 's/listen  443;/listen 443 ssl;\
        ssl_certificate \/etc\/nginx\/ssl\/invoiceninja.crt;\
        ssl_certificate_key \/etc\/nginx\/ssl\/invoiceninja.key;/g' \
        /etc/nginx/nginx.conf

# Generate our key
openssl genrsa 4096 > $DIR/invoiceninja.key

# Create the self-signed certificate for all invoiceninja
openssl req -new -x509 -nodes -sha256 -days 3650 -key $DIR/invoiceninja.key << ANSWERS > $DIR/invoiceninja.crt
JP
NinjaTown
NinjaCity
invoiceninja
Me
$SSL_HOSTNAME
admin@localhost
ANSWERS

