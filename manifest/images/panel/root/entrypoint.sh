#!/bin/sh

###
# /entrypoint.sh - Manages the startup of pterodactyl panel
###

# Prep Container for usage
function checkDatabase {
    # Check if MySQL is up and running
    echo "[init] Waiting for database connection..."
    i=0
    until wait-for -q -t 15 $DB_HOST:$DB_PORT; do
        echo "[init] Database connection timeout"

        # wait for 5 seconds before check again
        sleep 5
        i=`expr $i + 1`
        if [ "$i" = "5" ]; then
            echo "[init] Connection threshold reached, unable to contact MySQL (Is MySQL Running?)"
            exit 3
        fi
    done
}

# Runs the initial configuration on every startup
function startServer {
    echo ""
    cat .storage.tmpl | while read line; do
        mkdir -p "/data/${line}"
    done

    # Generate config file if it doesnt exist
    if [ ! -e /data/pterodactyl.conf ]; then
        echo ""
        echo "[setup] Generating Application Key..."

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

        echo "[setup] Application Key Generated"
    fi
    echo ""
    echo "[setup] Clearing cache/views..."
    
    php artisan view:clear
    php artisan config:clear

    echo ""
    echo "[setup] Migrating/Seeding database..."

    php artisan migrate --seed --force

    # Restore /data directory ownership to nginx.
    chown -R nginx:nginx /data/
    
    # Checks if SSL certificate and key exists, otherwise default to http traffic
    if [ -f "${SSL_CERT}" ] && [ -f "${SSL_CERT_KEY}" ]; then
        envsubst '${SSL_CERT},${SSL_CERT_KEY}' \
        < /etc/nginx/templates/https.conf > /etc/nginx/conf.d/default.conf
    else
        echo "[setup] Warning: SSL Certificate was not specified or doesnt exist, using HTTP."
        cat /etc/nginx/templates/http.conf > /etc/nginx/conf.d/default.conf
    fi

    echo "--- Starting Pterodactyl Panel: ${VERSION} ---"

    # Run these as jobs and monitor their pid status
    /usr/sbin/php-fpm8 --nodaemonize -c /etc/php8 & php_service_pid=$!
    /usr/sbin/nginx -g "daemon off;" & nginx_service_pid=$!

    # Monitor Child Processes
    while ( true ); do
        if ! kill -0 "$php_service_pid" 2>/dev/null; then
            echo "[php] service is no longer running! exiting..."
            sleep 5
            wait "$php_service_pid";
            exit 1
        fi
        if ! kill -0 "$nginx_service_pid" 2>/dev/null; then
            echo "[nginx] service is no longer running! exiting..."
            sleep 5
            wait "$nginx_service_pid"; 
            exit 2
        fi
        sleep 1
    done;
}

## Start ##

case "${1}" in
    p:start)
        checkDatabase
        startServer
        ;;
    p:worker)
        checkDatabase
        exec php /var/www/html/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
        ;;
    p:cron)
        checkDatabase
        exec /usr/sbin/crond -f -l 0
        ;;
    *)
        exec ${@}
        ;;
esac