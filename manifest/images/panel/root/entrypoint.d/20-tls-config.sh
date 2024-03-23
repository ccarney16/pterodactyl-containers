#!/bin/bash

# Configures Caddy's HTTP Configuration

export CADDY_APP_URL=${APP_URL}

case $SSL_CERT in
    acme )
        printf "[tls-config] ACME is enabled. Setting email address to ${SSL_CERT_KEY}"
        export CADDY_TLS_OPTIONS="tls ${SSL_CERT_KEY}"
        ;;
    internal )
        printf "[tls-config] Using Caddy's internal certificate store.\n"
        export CADDY_TLS_OPTIONS="tls internal"
        ;;
    none )
        printf "[tls-config] SSL_CERT is set to 'none', forcefully disabling https...\n"
        export CADDY_APP_URL="http://"
        export CADDY_TLS_OPTIONS=""
        ;;
    * )
        if [ -f "${SSL_CERT}" ] && [ -f "${SSL_CERT_KEY}" ]; then
            printf "[tls-config] Using external certificates.\n"
            export CADDY_TLS_OPTIONS="tls ${SSL_CERT} ${SSL_CERT_KEY}"
        else
            # Fallback to disabling https as to prevent issues with legacy installations
            printf "[tls-config] Cannot find SSL certificate and/or key, not injecting tls rules.\n"
            export CADDY_APP_URL="http://"
            export CADDY_TLS_OPTIONS=""
        fi
        ;;
esac
