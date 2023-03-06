#!/bin/bash

# Do not continue if data directory is not writable.
if [ ! -w /data ]; then
    printf "[volume-check] Error! /data directory is not writable! Please make sure that "caddy" (UID:$(id -u)) has write access.\n"
    exit 1
fi

# While /tmp may not be used by Pterodactyl, we will still issue a warning as PHP may require it.
if [ ! -w /tmp ]; then
    printf "[volume-check] Warning! /tmp is not writable, This container instance will continue to boot, however there may be some unintended side-effects!"
fi