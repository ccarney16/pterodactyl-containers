#!/bin/bash

# Parses TRUSTED_PROXIES for use in caddy before changing to wildcard

CADDY_TRUSTED_PROXIES=""

if ! [[ -z "$TRUSTED_PROXIES" ]]; then
    printf "[proxy-parser] Enabling trusted_proxies directive for web server.\n"
    export CADDY_TRUSTED_PROXIES="trusted_proxies $(echo "$TRUSTED_PROXIES" | sed 's/,/ /g')"

    # Resets TRUSTED_PROXIES for pterodactyl to accept any web proxy (caddy will handle which proxy is actually trusted)
    export TRUSTED_PROXIES="**"
fi
