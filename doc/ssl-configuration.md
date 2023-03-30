# SSL Configuration

Both panel and daemon web service support HTTPS.

## ACME

> At the time of this writing, both panel and daemon support getting certificates from Let's Encrypt, however
> both cannot be used at the same time and feature incompatible formats. If you want to run the panel and daemon
> and maintain SSL renewals, it is strongly suggested to use a reverse proxy like nginx or traefik to handle SSL.

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
