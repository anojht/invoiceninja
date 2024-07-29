[![Docker Pulls](https://img.shields.io/docker/pulls/anojht/invoiceninja.svg)](https://hub.docker.com/r/anojht/invoiceninja/)
[![Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://paypal.me/Anojh)

---

DockerFile for invoice ninja (https://www.invoiceninja.com/)

This image is based on `php:8.1-fpm-alpine` official version.

To make your data persistent, you have to mount `/var/www/app/public/logo` and `/var/www/app/storage`.

### Usage

To run it:

```
docker run -d
  -e APP_ENV='production'
  -e APP_DEBUG=0
  -e APP_URL='http://IPADDRESS:8000'
  -e APP_KEY='SomeRandom32CharacterLongAlphanumericString'
  -e DB_TYPE='mysql'
  -e DB_STRICT='false'
  -e DB_HOST='localhost'
  -e DB_DATABASE='ninja'
  -e DB_USERNAME='ninja'
  -e DB_PASSWORD='ninja'
  -e IN_USER_EMAIL='jane@example.com'
  -e IN_PASSWORD='secretpassword'
  -e TRUSTED_PROXIES='PROXYCIDR'
  -e MAIL_DRIVER='smtp'
  -e MAIL_PORT='587'
  -e MAIL_ENCRYPTION='tls'
  -e MAIL_HOST='smtp.example.com'
  -e MAIL_USERNAME='johndoe@example.com'
  -e MAIL_FROM_ADDRESS='sales@example.com'
  -e MAIL_FROM_NAME='Sales Department'
  -e MAIL_PASSWORD='SUPERSECRETEMAILPASSWORD'
  -e SSL_HOSTNAME='localhost'
  -p '8000:80'
  -p '443:443'
  anojht/invoiceninja
```

A list of environment variables can be found [here](https://github.com/invoiceninja/invoiceninja/blob/master/.env.example)

### For v4 of the application

Change your image tag to point to anojht/invoiceninja:v4
