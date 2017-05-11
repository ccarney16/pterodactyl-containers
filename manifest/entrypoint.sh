#!/bin/sh

###
# /entrypoint.sh - Manages the startup of pterodactyl panel
###

set -e

# Prep Container for usage
function init {
    # Create the storage directory
    if [ ! -d ${STORAGE_DIR} ]; then
        cp ./storage.template ${STORAGE_DIR} -pr
    fi

    rm -rf ./storage
    ln -s ${STORAGE_DIR} ./storage

    # Always destroy .env symlink on startup
    rm .env -rf
    ln -s "${CONFIG_FILE}" .env

    if [ ! -e "${CONFIG_FILE}" ] || [ ! -s "${CONFIG_FILE}" ]; then
        echo "Missing Configuration file, Creating..."

        cp .env.example "${CONFIG_FILE}"

        php artisan optimize
        php artisan config:cache
        php artisan key:generate --force

        updateConfiguration
    fi

    php artisan optimize
    php artisan config:cache

}

# Runs the initial configuration on every startup
function initServer {
    if [[ -z "${APP_URL}" ]]; then
        echo "Missing environment variable 'APP_URL'! Please resolve it now and start the container back up..."
        exit 1;
    fi

    if [[ "${STARTUP_TIMEOUT}" -gt "0" ]]; then
        echo "Starting Pterodactyl ${PANEL_VERSION} in ${STARTUP_TIMEOUT} seconds..."
        sleep ${STARTUP_TIMEOUT}
    else 
        echo "Starting Pterodactyl ${PANEL_VERSION}..."
    fi


    # Since Nginx does not support URL's, lets just pull the domain out of the URL
    export DOMAIN_NAME="$(echo $APP_URL | awk -F/ '{print $3}')"

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
}

# Updates a configuration using variables from the .env file and shell variables
function updateConfiguration {

    php artisan pterodactyl:env -n \
    --url="${APP_URL}" \
    --dbhost="${DB_HOST}" \
    --dbport="${DB_PORT}" \
    --dbname="${DB_DATABASE}" \
    --dbuser="${DB_USERNAME}" \
    --dbpass="${DB_PASSWORD}" \
    --driver="${CACHE_DRIVER}" \
    --session-driver=database \
    --queue-driver=database \
    --timezone="${TIMEZONE}"

    php artisan pterodactyl:mail -n \
    --driver="${MAIL_DRIVER}" \
    --email="${MAIL_FROM}" \
    --host="${MAIL_HOST}" \
    --port="${MAIL_PORT}" \
    --username="${MAIL_USERNAME}" \
    --password="${MAIL_PASSWORD}" \
    --from-name="${MAIL_FROM_NAME}"

    php artisan migrate --force

    php artisan db:seed --force
}

## Start ##

init

case "$1" in
    p:start)
        initServer
        exec supervisord --nodaemon
        ;;
    p:update)
        updateConfiguration
        ;;
    *)
        echo -e "No internal command specified, executing as shell command...\n"
        exec $@
        ;;
esac
