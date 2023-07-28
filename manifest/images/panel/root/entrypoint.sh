#!/bin/bash

###
# /entrypoint.sh - Manages the startup of the web application
###

# Runs the initial configuration on every startup
function start_server {

    # Create and set permissions for php session directory
    echo "[init] Creating PHP Cache Directories"
    mkdir -p /var/lib/caddy/php/{session,opcache,wsdlcache}
    chmod 770 /var/lib/caddy/php/{session,opcache,wsdlcache}

    # Allows this container to have extra functionality on init
    if [ -d /entrypoint.d ]; then
        echo "[init] /entrypoint.d exists. Executing pre-start functions"
        for exec in /entrypoint.d/*.sh; do
            source $exec
        done
    fi

    # Output loaded php modules before runtime.
    printf "[init] Caddy Version: $(caddy version)\n"
    _php_info=$(php -r "echo $PHP_VERSION;")
    printf "[init] PHP Version: $_php_info\n"
    printf "[init] Loaded PHP Modules:"
    php -m | tr '\n' ' ' | sed 's/\[/\n  &/g'
    printf "\n"

    echo "--- Starting Web Server ---"

    # Run these as jobs and monitor their pid status
    /usr/sbin/php-fpm --nodaemonize --pid /var/lib/caddy/.php-fpm.pid & php_service_pid=$!
    /usr/bin/caddy run --pidfile /var/lib/caddy/.caddy.pid --config /etc/caddy/Caddyfile & caddy_service_pid=$!

    # Monitor Child Processes
    while ( true ); do
        if ! kill -0 "$php_service_pid" 2>/dev/null; then
            echo "[php-fpm] service is no longer running! exiting..."
            sleep 1
            exit 1
        fi
        if ! kill -0 "$caddy_service_pid" 2>/dev/null; then
            echo "[caddy] service is no longer running! exiting..."
            sleep 1
            exit 2
        fi
        sleep 5
    done;
}

# Get User ID
user_id="$(id -u)"

# init Startup script before performing anything else, ideally should be short and concise
if [ -f /entrypoint.init.sh ]; then
    source /entrypoint.init.sh
fi

# Set ownership of stdout/stderr and run as caddy if running as root
# This is set to maintain compatibility with existing installations that ran mainly as root.
if [ "$user_id" = "0" ]; then
    chown --dereference caddy "/proc/$$/fd/1" "/proc/$$/fd/2"
    exec runuser --user caddy -- "$BASH_SOURCE" "$@"
fi

case "${1}" in
    "")
        ;;
    "start-web")
        start_server
        ;;
    "cron")
        yacron -c /etc/yacron.d
        ;;
    *)
        exec "$@"
        ;;
esac
