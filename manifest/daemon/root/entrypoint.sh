#!/bin/sh

echo "Checking for Daemon Configuration..."
while [ ! -f /etc/pterodactyl/config.yml ]; do
    echo "Daemon config does not exist! Waiting..."
    sleep 5
done

echo "Config found, starting daemon..."

/usr/local/bin/wings