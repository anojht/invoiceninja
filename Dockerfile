ARG PHP_IMAGE_TAG=7.4-fpm-alpine
FROM php:${PHP_IMAGE_TAG}

LABEL maintainer="Anojh Thayaparan <athayapa@sfu.ca>"

#####
# SYSTEM REQUIREMENT
#####
ENV PHANTOMJS phantomjs-2.1.1-linux-x86_64
RUN apk update \
	&& apk add --no-cache git gmp-dev freetype-dev libjpeg-turbo-dev \
	libzip-dev unzip nginx nano coreutils chrpath fontconfig libpng-dev \
	bash php7-zip php7-pdo php7-pdo_mysql supervisor

RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
	&& docker-php-ext-configure gmp \
	&& docker-php-ext-install iconv pdo pdo_mysql gd gmp opcache zip \
	&& echo "php_admin_value[error_reporting] = E_ALL & ~E_NOTICE & ~E_WARNING & ~E_STRICT & ~E_DEPRECATED">>/usr/local/etc/php-fpm.d/www.conf

RUN cd /usr/share \
	&& curl  -L https://github.com/Overbryd/docker-phantomjs-alpine/releases/download/2.11/phantomjs-alpine-x86_64.tar.bz2 | tar xj \
	&& ln -s /usr/share/phantomjs/phantomjs /usr/local/bin/phantomjs

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
	echo 'opcache.memory_consumption=128'; \
	echo 'opcache.interned_strings_buffer=8'; \
	echo 'opcache.max_accelerated_files=4000'; \
	echo 'opcache.revalidate_freq=60'; \
	echo 'opcache.fast_shutdown=1'; \
	echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#####
# DOWNLOAD AND INSTALL INVOICE NINJA
#####

ENV INVOICENINJA_VERSION 4.5.50

RUN curl -o ninja.zip -SL https://download.invoiceninja.com/ninja-v${INVOICENINJA_VERSION}.zip \
	&& unzip -q ninja.zip -d /var/www/ \
	&& rm ninja.zip \
	&& mv /var/www/ninja /var/www/app \
	&& mv /var/www/app/storage /var/www/app/docker-backup-storage \
	&& mv /var/www/app/public /var/www/app/docker-backup-public \
	&& mkdir -p /var/www/app/public/logo /var/www/app/storage \
	&& touch /var/www/app/.env \
	&& chmod -R 755 /var/www/app/storage \
	&& chown -R www-data:www-data /var/lib/nginx /var/log/nginx /var/www/app/storage /var/www/app/bootstrap /var/www/app/public/logo /var/www/app/.env /var/www/app/docker-backup-storage /var/www/app/docker-backup-public \
	&& rm -rf /var/www/app/docs /var/www/app/tests /var/www/ninja

######
# DEFAULT ENV
######
ENV LOG errorlog
ENV SELF_UPDATER_SOURCE ''
ENV PHANTOMJS_BIN_PATH /usr/local/bin/phantomjs


#use to be mounted into nginx for example
VOLUME /var/www/app/public

WORKDIR /var/www/app

COPY docker-compose/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker-compose/nginx.conf /etc/nginx/nginx.conf
COPY docker-compose/genssl.sh /genssl.sh
EXPOSE 80

COPY docker-compose/cronscript.sh /cronscript.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /cronscript.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
