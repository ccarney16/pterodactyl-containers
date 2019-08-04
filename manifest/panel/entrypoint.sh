#!/bin/sh

###
# /entrypoint.sh - Manages the startup of pterodactyl panel
###

# Prep Container for usage
function init {
    # Create the storage/cache directories
    if [ ! -d /data/storage ]; then
        mkdir -p /data/storage
        cat .storage.tmpl | while read line; do
            mkdir -p "/data/${line}"
        done
        chown -R nginx:nginx /data/storage
    fi

    if [ ! -d /data/cache ]; then
        mkdir -p /data/cache
        chown -R nginx:nginx /data/cache
    fi

    # destroy links (or files) and recreate them
    rm -rf storage
    ln -s /data/storage storage

    rm -rf bootstrap/cache
    ln -s /data/cache bootstrap/cache

    rm -rf .env
    ln -s /data/pterodactyl.conf .env
}

# Runs the 
ial configuration on every startup
function startServer {

    # Initial setup
    if [ ! -e /data/pterodactyl.conf ]; then
        echo "Running first time setup..."

        # Generate base template
        touch /data/pterodactyl.conf
        echo "##" > /data/pterodactyl.conf
        echo "# Generated on:" $(date +"%B %d %Y, %H:%M:%S") >> /data/pterodactyl.conf
        echo "# This file was generated on first start and contains " >> /data/pterodactyl.conf
        echo "# the key for sensitive information. All panel configuration " >> /data/pterodactyl.conf
        echo "# can be done here using the normal method (NGINX not included!)," >> /data/pterodactyl.conf
        echo "# or using Docker's environment variables parameter." >> /data/pterodactyl.conf
        echo "##" >> /data/pterodactyl.conf
        echo "" >> /data/pterodactyl.conf
        echo "APP_KEY=SomeRandomString3232RandomString" >> /data/pterodactyl.conf

        sleep 5

        echo ""
        echo "Generating key..."
        sleep 1
        php artisan key:generate --force --no-interaction

        echo ""
        echo "Creating & seeding database..."
        sleep 1
        php artisan migrate --force
        php artisan db:seed --force
    fi


    # CHecking is mobile app enalbed
    if [ "${MOBILE_APP}" == "true" ]; then
       echo "[INFO] Mobile app is enabled"

        # This is a empty file and was only created for first time setup and not running every time
        if [ ! -e /data/pterodactyl-mobile.conf ]; then
            echo "Running first time mobile app setup..."

            # Generate base template
            touch /data/pterodactyl-mobile.conf

            # Setup mobile app
            composer config repositories.cloud composer https://packages.pterodactyl.cloud
            composer require pterodactyl/mobile-addon --update-no-dev --optimize-autoloader
            php artisan migrate
        fi
    else
        echo "[INFO] Mobile app is disabled"
    fi

    # Allows Users to give MySQL/cache sometime to start up.
    if [[ "${STARTUP_TIMEOUT}" -gt "0" ]]; then
        echo "Starting Pterodactyl ${PANEL_VERSION} in ${STARTUP_TIMEOUT} seconds..."
        sleep ${STARTUP_TIMEOUT}
    else 
        echo "Starting Pterodactyl ${PANEL_VERSION}..."
    fi

    if [ "${SSL}" == "true" ]; then
        envsubst '${SSL_CERT},${SSL_CERT_KEY}' \
        < /etc/nginx/templates/https.conf > /etc/nginx/conf.d/default.conf
    else
        echo "[Warning] Disabling HTTPS"
        cat /etc/nginx/templates/http.conf > /etc/nginx/conf.d/default.conf
    fi

    # Determine if workers should be enabled or not
    if [ "${DISABLE_WORKERS}" != "true" ]; then
        /usr/sbin/crond -f -l 0 &
        php /var/www/html/artisan queue:work database --queue=high,standard,low --sleep=3 --tries=3 &
    else 
        echo "[Warning] Disabling Workers (pteroq & cron); It is recommended to keep these enabled unless you know what you are doing."
    fi

    /usr/sbin/php-fpm7 --nodaemonize -c /etc/php7 &

    exec /usr/sbin/nginx -g "daemon off;"
}

## Start ##

init

case "${1}" in
    p:start)
        startServer
        ;;
    *)
        exec ${@}
        ;;
esac
