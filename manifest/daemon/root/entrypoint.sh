#!/bin/sh

echo "Pre-start: Checking for Daemon configuration..."

count=1
while [ ! -f /etc/pterodactyl/config.yml ]; do
    echo "Pre-start: Daemon config does not exist... Waiting [Try "$count"]"
    count=`expr $count + 1`
    sleep 15
done

echo "Pre-start: Config found"

echo "Starting Pterodactyl Daemon ${VERSION}..."

exec /usr/local/bin/wings