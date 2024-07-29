ARG PHP_VERSION=8.2
ARG BAK_STORAGE_PATH=/var/www/app/docker-backup-storage/
ARG BAK_PUBLIC_PATH=/var/www/app/docker-backup-public/

# Get Invoice Ninja and install nodejs packages
FROM --platform=$BUILDPLATFORM node:lts-alpine as nodebuild

# Download Invoice Ninja
ARG INVOICENINJA_VERSION
ARG REPOSITORY=invoiceninja/invoiceninja

ARG FILENAME=invoiceninja.tar

RUN set -eux; apk add curl unzip grep

# Fetch the latest release information
RUN DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/invoiceninja/invoiceninja/releases/latest" | grep -o '"browser_download_url": "[^"]*invoiceninja.tar"' | cut -d '"' -f 4) && \
	curl -LJO "$DOWNLOAD_URL" && \
	mv invoiceninja.tar /tmp/ninja.tar

# Extract Invoice Ninja
RUN mkdir -p /var/www/app \
	&& tar -xvf /tmp/ninja.tar -C /var/www/app/ \
	&& mkdir -p /var/www/app/public/logo /var/www/app/storage

WORKDIR /var/www/app

# Prepare php image
FROM php:${PHP_VERSION}-fpm-alpine as phpbuild

LABEL maintainer="Anojh Thayaparan <athayapa@sfu.ca>"

# Adding caching_sha2_password.so
# With this we get native support for caching_sha2_password
RUN apk add --no-cache mariadb-connector-c

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Install PHP extensions
# https://hub.docker.com/r/mlocati/php-extension-installer/tags
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Install chromium
RUN set -eux; \
	apk add --no-cache \
	font-isas-misc \
	supervisor \
	mysql-client \
	chromium \
	ttf-freefont \
	ttf-dejavu \
	nginx

RUN install-php-extensions \
	bcmath \
	exif \
	gd \
	gmp \
	mysqli \
	opcache \
	pdo_mysql \
	zip \
	intl \
	@composer \
	&& rm /usr/local/bin/install-php-extensions

# Copy files
COPY rootfs /

## Create user
ARG UID=1500
ENV INVOICENINJA_USER invoiceninja

RUN addgroup --gid=$UID -S "$INVOICENINJA_USER" \
	&& adduser --uid=$UID \
	--disabled-password \
	--gecos "" \
	--home "/var/www/app" \
	--ingroup "$INVOICENINJA_USER" \
	"$INVOICENINJA_USER"

# Set up app
ARG INVOICENINJA_VERSION
ARG BAK_STORAGE_PATH
ARG BAK_PUBLIC_PATH
ENV INVOICENINJA_VERSION $INVOICENINJA_VERSION
ENV BAK_STORAGE_PATH $BAK_STORAGE_PATH
ENV BAK_PUBLIC_PATH $BAK_PUBLIC_PATH
COPY --from=nodebuild --chown=$INVOICENINJA_USER:$INVOICENINJA_USER /var/www/app /var/www/app

RUN rm -rf /var/www/app/ui

USER invoiceninja
WORKDIR /var/www/app

# Do not remove this ENV
ENV IS_DOCKER true
FROM --platform=$BUILDPLATFORM nodebuild AS dependencybuild

WORKDIR /var/www/app
COPY --from=phpbuild /var/www/app/vendor /var/www/app/vendor

# Install node packages
ARG BAK_STORAGE_PATH
ARG BAK_PUBLIC_PATH

RUN mv /var/www/app/storage $BAK_STORAGE_PATH \
	&& mv /var/www/app/public $BAK_PUBLIC_PATH

FROM phpbuild as prodbuild

COPY --from=dependencybuild --chown=$INVOICENINJA_USER:$INVOICENINJA_USER /var/www/app /var/www/app

USER root

RUN	mkdir -p /run/nginx /var/www/app/public /var/www/app/public/storage/backups \
	&& chown -R www-data:www-data /var/lib/nginx/tmp /var/lib/nginx /var/www/app/ \
	&& rm -rf /var/www/app/.env \
	&& sed -i -e 's/memory_limit = 128M/memory_limit = 256M/g' /usr/local/etc/php/php.ini

# Override the environment settings from projects .env file
ENV APP_ENV production
ENV LOG errorlog
ENV SNAPPDF_EXECUTABLE_PATH /usr/bin/chromium-browser

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
CMD ["supervisord"]
