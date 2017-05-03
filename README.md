# Pterodactyl Panel Dockerfile #
__A Free and Open Source Agnostic Game Panel__

### Usage ###
---
Docker: `docker run --name=pterodactyl-panel -p 80:80 -p 443:443 --env-file=./.env quay.io/ccarney/pterodactyl-panel:v0.6.0-rc.1`

__or__

Docker Compose: `docker-compose up`

Please refer to ENVIRIONMENT.md for more information regarding environment variables.

### Docker Compose ###
---
This repo provides a template docker-compose.yml file for easier deployment for the panel. It is highly recommended to use over straight up Docker.

### Updating ###
---
__Minor Revisions & Configuration Changes:__

Docker: `docker run --rm -v <root>:/data --env-file=./.env quay.io/ccarney/pterodactyl-panel:v0.6.0 p:update`

Docker Compose: `docker-compose run --rm panel p:update`

__From v0.5.x to v0.6.x:__

*TBA...*


### SSL Encryption ###
---
SSL Encryption is an optional but recommended feature. Automatic SSL is provided by Let's Encrypt. When using the webroot feature in certbot (refer to docker-compose.yml), you should mount the .well-known directory created to `/var/www/html/.well-known` within the panel container.

### Contributing ###
---
All issues regarding Pterodactyl Panel/Node are to be reported to https://github.com/Pterodactyl/Panel/issues.