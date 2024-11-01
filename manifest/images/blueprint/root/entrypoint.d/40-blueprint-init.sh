#!/usr/bin/env bash

##
# blueprint-init.sh
#   Initializes blueprint extensions on startup
##

if ! [ -d /data/blueprint_extensions ]; then
    mkdir -p /data/blueprint_extensions
fi

rsync -av --exclude=".blueprint" --include="*.blueprint*" --exclude="*" --delete /data/blueprint_extensions/ /var/www/html/
