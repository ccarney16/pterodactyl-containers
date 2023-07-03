# SSL Configuration

Both panel and daemon web service support HTTPS.

## ACME

> **This is considered experimental!** Previous builds of this project contains certbot, however that has been removed and replaced with
> caddy. Both Panel and Daemon can grab certificates, however at this moment only one or the other can grab them. This documentation will
> only provide documentation for the panel at this moment. If you need access to Let's Encrypt, please use a reverse proxy like NGINX or Traefik.

The web panel comes with caddy which supports getting ssl certificates, The following can be updated in `conf.d/panel.env`

```
SSL_CERT="acme"
SSL_CERT_KEY="<email>"

APP_URL="https://<domain>"
```

The daemon has this built in, but will need port 443 opened along with the following command line parameters in docker-compose:

```
command: --auto-tls --tls-hostname <domain>
```

## Manual SSL Certificates

By default, certificates are to be placed into `conf.d/certs`, which are mapped to both panel and daemon as `/etc/certs`.
