#!/bin/sh

###
# /entrypoint.sh - Manages the startup of pterodactyl panel
###

# Prep Container for usage
function init {
    # Create the storage/cache directory
    if [ ! -d /data/storage ]; then
        cp -pr storage.tmpl /data/storage
    fi

    if [ ! -d /data/cache ]; then
        mkdir -p /data/cache
        chown -R nginx:nginx /data/cache
    fi

    # destroy links and recreate them
    rm -rf storage
    ln -s /data/storage storage

    rm -rf bootstrap/cache
    ln -s /data/cache bootstrap/cache

    rm .env -rf
    ln -s "${CONFIG_FILE}" .env
}

# Runs the initial configuration on every startup
function startServer {

    # Initial setup
    if [ ! -e "${CONFIG_FILE}" ]; then
        echo "Running first time setup..."

        cp -pr .env.example ${CONFIG_FILE}

        sleep 5

        # Clean out everything
        php artisan config:cache
        php artisan optimize

        echo ""
        echo "Generating key..."
        sleep 1
        php artisan key:generate --force

        echo ""
        echo "Creating & seeding database..."
        sleep 1
        php artisan migrate --force
        php artisan db:seed --force

        php artisan config:cache
        php artisan optimize
    fi

    if [[ "${STARTUP_TIMEOUT}" -gt "0" ]]; then
        echo "Starting Pterodactyl ${PANEL_VERSION} in ${STARTUP_TIMEOUT} seconds..."
        sleep ${STARTUP_TIMEOUT}
    else 
        echo "Starting Pterodactyl ${PANEL_VERSION}..."
    fi

    # Checks if we have SSL enabled or not, and updates the configuration to what is desired.
    if [ "${SSL}" == "true" ]; then
        echo "Enabling SSL"

        envsubst '${DOMAIN_NAME},${SSL_CERT},${SSL_CERT_KEY}' \
        < /etc/nginx/templates/https.conf.tmpl > /etc/nginx/conf.d/default.conf
    else
        echo "Disabling SSL"

        envsubst '${DOMAIN_NAME}' \
        < /etc/nginx/templates/http.conf.tmpl > /etc/nginx/conf.d/default.conf
    fi

    exec supervisord --nodaemon
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
