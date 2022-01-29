[![Docker Pulls](https://img.shields.io/docker/pulls/anojht/invoiceninja.svg)](https://hub.docker.com/r/anojht/invoiceninja/)
[![Paypal](https://img.shields.io/badge/paypal-donate-yellow.svg)](https://paypal.me/Anojh)

---

DockerFile for invoice ninja (https://www.invoiceninja.com/)

This image is based on `php:7.4-fpm-alpine` official version.

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
  -p '80:8000'
  -p '443:443'
  invoiceninja/invoiceninja
```

A list of environment variables can be found [here](https://github.com/invoiceninja/invoiceninja/blob/master/.env.example)

### SSL

By default, it generates self signed certificates, however you can provide custom ones via env variables at run time:

```
$SSL_KEY
$SSL_CERT
```

If you want to disable generation of SSL certificates, simply pass env var `GEN_SSL=false` at runtime.

### With docker-compose

A pretty ready to use docker-compose configuration can be found into [`./docker-compose`](https://github.com/invoiceninja/dockerfiles/tree/master/docker-compose).
Rename `.env.example` into `.env` and change the environment's variable as needed.
The file assume that all your persistent data is mounted from `/mnt/user/appdata/invoiceninja/`.
Once started the application should be accessible at http://IPADDRESS:8000/
