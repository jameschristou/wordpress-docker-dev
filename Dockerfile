# Used to create the base image for our WP CMS dev environments

FROM wordpress:5.4-php7.3-apache

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends less libmemcached-dev libxml2-dev libz-dev \
    && docker-php-ext-install soap \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install memcached xdebug \
    && docker-php-ext-enable memcached xdebug \
    && rm -rf /tmp/pear/

RUN { \
      echo ''; \
      echo 'xdebug.remote_enable=1'; \
      echo 'xdebug.remote_autostart=1'; \
      echo 'xdebug.remote_port="9000"'; \
      echo 'xdebug.remote_host="host.docker.internal"'; \
    } >> /usr/local/etc/php/conf.d/xdebug.ini

VOLUME /var/www/html

RUN curl -sSL -o /usr/local/bin/wp "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" \
    && chmod +x /usr/local/bin/wp \
    && mkdir -p /etc/wp-cli \
    && chown www-data:www-data /etc/wp-cli

RUN { \
      echo 'path: /var/www/html'; \
      echo 'url: wordpress.dev'; \
      echo 'apache_modules:'; \
      echo '  - mod_rewrite'; \
    } > /etc/wp-cli/config.yml

RUN echo "export WP_CLI_CONFIG_PATH=/etc/wp-cli/config.yml" > /etc/profile.d/wp-cli.sh

COPY dev-docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["dev-docker-entrypoint.sh"]
CMD ["apache2-foreground"]