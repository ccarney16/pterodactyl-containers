#!/bin/bash

# performs checks before the application is executed

# Do not continue if data directory is not writable.
if [ ! -w /data ]; then
    printf "[volume-check] Error! /data directory is not writable! Please make sure that "caddy" (UID:$(id -u caddy)) has write access.\n"
    exit 1
fi

# While /tmp may not be used by Pterodactyl, we will still issue a warning as PHP may require it.
if [ ! -w /tmp ]; then
    printf "[volume-check] Warning! /tmp is not writable, This container instance will continue to boot, however there may be some unintended side-effects!"
fi

# Check if MySQL is up and running
echo "[wait-for-mysql] Waiting for database connection..."
i=0
until wait-for -q -t 15 $DB_HOST:$DB_PORT; do
    echo "[wait-for-mysql] Database connection timeout"

    # wait for 5 seconds before check again
    sleep 5
    i=`expr $i + 1`
    if [ "$i" = "5" ]; then
        echo "[wait-for-mysql] Connection threshold reached, unable to contact MySQL (Is MySQL Running?)"

        exit 1
    fi
done
