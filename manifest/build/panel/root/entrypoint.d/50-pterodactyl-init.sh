#!/bin/bash

cat .storage.tmpl | while read line; do
    mkdir -p "/data/${line}"
done

# Generate config file if it doesnt exist
if [ ! -e /data/pterodactyl.conf ]; then
    printf "\n[pterodactyl-init] Generating Application Key...\n"

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

    printf "[pterodactyl-init] Application Key Generated\n"
fi

printf "\n[pterodactyl-init] Clearing cache/views...\n"
    
php artisan view:clear
php artisan config:clear

printf "\n[pterodactyl-init] Migrating/Seeding database...\n"

php artisan migrate --seed --force
