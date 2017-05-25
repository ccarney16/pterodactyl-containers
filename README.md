# Pterodactyl Panel Dockerfile #
__A Free and Open Source Agnostic Game Panel__

https://github.com/ccarney16/pterodactyl-panel-dockerfile

### Usage ###

---

Docker:

It is recommended to create a environment file and run the following command:
`docker run --name=pterodactyl-panel -p 80:80 -p 443:443 --env-file=./.env quay.io/ccarney/pterodactyl-panel:v0.6.1`

__or__

Docker Compose:

Edit the environment section within docker-compose.yml then run `docker-compose up`

Please refer to ENVIRIONMENT.md for more information regarding environment variables.

### Docker Compose ###

---

This repo provides a template docker-compose.yml file for easier deployment for the panel. It is highly recommended to use over straight up Docker.

### Updating ###

---

__Minor Revisions & Configuration Changes:__

Docker:

It is recommended to create a environment file and run the following command: `docker run --rm -v <root>:/data --env-file=./.env quay.io/ccarney/pterodactyl-panel:v0.6.0 p:update`

Docker Compose:

Edit the environment section within docker-compose.yml then run `docker-compose run --rm panel p:update`

__From v0.5.x to v0.6.x:__

*TBA...*

### Entrypoint Commands ###

---

* p:start - Starts the panel webserver and requirements (We don't provide Memcached!).
* p:update - Updates the panel config using environment variables on runtime.

### SSL Encryption ###

---

SSL Encryption is an optional but recommended feature. Automatic SSL is provided by Let's Encrypt. When using the webroot feature in certbot (refer to docker-compose.yml), you should mount the .well-known directory created to `/var/www/html/.well-known` within the panel container.

### Contributing ###

---

All issues regarding Pterodactyl Panel/Node are to be reported to https://github.com/Pterodactyl/Panel/issues.

### Useful Links ###

---

Pterodactyl Project:

https://pterodactyl.io

https://docs.pterodactyl.io

https://github.com/Pterodactyl
