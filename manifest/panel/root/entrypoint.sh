#!/bin/sh

###
# /entrypoint.sh - Manages the startup of pterodactyl panel
###

# Prep Container for usage
function initContainer {
    # Check if MySQL is up and running
    echo "Pre-start: Waiting for database connection..."
    i=0
    until wait-for -t 30 $DB_HOST:$DB_PORT; do
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
    echo ""
    cat .storage.tmpl | while read line; do
        mkdir -p "/data/${line}"
    done

    mkdir -p /data/cache

    # Generate config file if it doesnt exist
    if [ ! -e /data/pterodactyl.conf ]; then
        echo ""
        echo "Setup: Generating key..."

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

        sleep 1
        php artisan key:generate --force --no-interaction

        echo "--Pterodactyl Key Generated--"
    fi

    chown -R nginx:nginx /data/

    echo ""
    echo "Clearing cache/views..."
    
    php artisan view:clear
    php artisan config:clear

    echo ""
    echo "Migrating/Seeding database..."

    php artisan migrate --seed --force

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

initContainer

case "${1}" in
    p:start)
        startServer
        ;;
    # Legacy setup, These will be removed in the near future
    p:worker)
        exec php /var/www/html/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
        ;;
    p:cron)
        exec /usr/sbin/crond -f -l 0
        ;;
    *)
        exec ${@}
        ;;
esac
