#!/bin/sh

###
# /entrypoint.sh - Manages the startup of the pterodactyl panel
###

set -e

# Runs the initial configuration on every startup
function init {
    if [[ -z "${PANEL_URL}" ]]; then 
        echo "Missing environment variable 'PANEL_URL'! Please resolve it now and start the container back up..."
        exit 1;
    fi

    echo "Starting Pterodactyl ${PANEL_VERSION} in ${STARTUP_TIMEOUT} seconds..."
    sleep ${STARTUP_TIMEOUT}

    DOMAIN_NAME="$(echo $PANEL_URL | awk -F/ '{print $3}')"

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

    initConfig
}

# Build the config only
function initConfig {

    # Create the storage directory
    if [ ! -d ${STORAGE_DIR} ]; then
        cp ./storage.template ${STORAGE_DIR} -pr
    fi

    rm -rf ./storage
    ln -s ${STORAGE_DIR} ./storage
    
    # Always destroy .env on startup
    rm .env -rf
    ln -s "${CONFIG_FILE}" .env

    if [ ! -e "${CONFIG_FILE}" ] || [ ! -s "${CONFIG_FILE}" ]; then
        echo "Missing Configuration file, Creating..."
        
        cp .env.example "${CONFIG_FILE}"
        
        php artisan key:generate --force
        
        updateConfiguration
    fi
}

# Updates a configuration using variables from the .env file and shell variables
function updateConfiguration {

    # Might looks like overkill, however we should optimize and clear the config cache
    php artisan optimize
    php artisan config:cache

    php artisan pterodactyl:env -n \
    --url="${PANEL_URL}" \
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

# Adds a new user to pterodactyl
function addUser {
    php artisan pterodactyl:user
}

## Start ##

case "$1" in
    p:start)
        init

        exec supervisord --nodaemon
        ;;
    p:update)
        initConfig

        updateConfiguration
        ;;
    *)
        initConfig

        echo -e "No internal command specified, executing as shell command...\n"
        exec $@
        ;;
esac