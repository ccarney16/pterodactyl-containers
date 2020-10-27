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
    fi

    if [ ! -d /data/cache ]; then
        mkdir -p /data/cache
    fi

    chown -R nginx:nginx /data/

    # destroy links (or files) and recreate them
    rm -rf storage
    ln -s /data/storage storage

    rm -rf bootstrap/cache
    ln -s /data/cache bootstrap/cache

    rm -rf .env
    ln -s /data/pterodactyl.conf .env

    # Check if MySQL is up and running
    echo "Pre-start: Waiting for database connection..."
    i=0
    until nc -z -v -w30 $DB_HOST $DB_PORT; do
        # wait for 5 seconds before check again
        sleep 5
        i=`expr $i + 1`
        if [ "$i" = "5" ]; then
            echo "Pre-start: Database Connection Timeout (Is MySQL Running?)"
            exit
        fi
    done
}

# Runs the initial configuration on every startup
function startServer {

    # Initial setup
    if [ ! -e /data/pterodactyl.conf ]; then
        echo "Setup: Running first time setup..."

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
        echo "Setup: Generating key..."
        sleep 1
        php artisan key:generate --force --no-interaction

        echo ""
        echo "Setup: Creating & seeding database..."
        sleep 1
        php artisan migrate --force
        php artisan db:seed --force


        echo "--Pterodactyl Setup completed!--"
    fi

    if [ "${SSL}" == "true" ]; then
        envsubst '${SSL_CERT},${SSL_CERT_KEY}' \
        < /etc/nginx/templates/https.conf > /etc/nginx/conf.d/default.conf
    else
        echo "Warning: Disabling HTTPS"
        cat /etc/nginx/templates/http.conf > /etc/nginx/conf.d/default.conf
    fi

   echo "Starting Pterodactyl Panel ${VERSION}..."

    /usr/sbin/php-fpm7 --nodaemonize -c /etc/php7 &

    exec /usr/sbin/nginx -g "daemon off;"
}

## Start ##

init

case "${1}" in
    p:start)
        startServer
        ;;
    p:worker)
        exec /usr/sbin/crond -f -l 0
        ;;
    p:cron)
        exec php /var/www/html/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
        ;;
    *)
        exec ${@}
        ;;
esac
