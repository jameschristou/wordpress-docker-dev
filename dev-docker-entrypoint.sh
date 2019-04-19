#!/bin/bash

set -ex

# remove exec line from the official wordpress docker-entrypoint.sh because we want to run that at end of this .sh
sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh

echo "Calling the wordpress base image entrypoint"
source /usr/local/bin/docker-entrypoint.sh

# enable full debug including display and log. The functions here are copied from the docker-entrypoint.sh
sed_escape_lhs() {
  echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
  echo "$@" | sed -e 's/[\/&]/\\&/g'
}
php_escape() {
  local escaped="$(php -r 'var_export(('"$2"') $argv[1]);' -- "$1")"
  if [ "$2" = 'string' ] && [ "${escaped:0:1}" = "'" ]; then
    escaped="${escaped//$'\n'/"' + \"\\n\" + '"}"
  fi
  echo "$escaped"
}
set_config() {
  key="$1"
  value="$2"
  var_type="${3:-string}"
  start="(['\"])$(sed_escape_lhs "$key")\2\s*,"
  end="\);"
  if [ "${key:0:1}" = '$' ]; then
    start="^(\s*)$(sed_escape_lhs "$key")\s*="
    end=";"
  fi
  sed -ri -e "s/($start\s*).*($end)$/\1$(sed_escape_rhs "$(php_escape "$value" "$var_type")")\3/" wp-config.php
}

set_config 'WP_DEBUG' 1 boolean
set_config 'WP_DEBUG_LOG' 1 boolean
set_config 'WP_DEBUG_DISPLAY' 1 boolean

ROOT_DIR=/var/www/html
WEB_USER=www-data

# Update WP-CLI config with current virtual host.
sed -i -E "s#^url: .*#url: ${WORDPRESS_SITE_URL:-http://wordpress.dev}#" /etc/wp-cli/config.yml

# Make sure uploads directory exists and is writeable.
mkdir -p $ROOT_DIR/wp-content/uploads
chown $WEB_USER:$WEB_USER $ROOT_DIR/wp-content
chown -R $WEB_USER:$WEB_USER $ROOT_DIR/wp-content/uploads

exec "$@"