# Pterodactyl Panel Dockerfile #
#### Free and Open Source Agnostic Game Panel ####

### Usage ###
This Github Repository provides a docker-compose.yml for an easy to start environment. 

Docker: `docker --name=pterodactyl-panel -e PANEL_URL=localhost run quay.io/ccarney/pterodactyl-panel:v0.6.0-rc.1`*

Docker Compose: `docker-compose up`

Please refer to ENVIRIONMENT.txt for more information regarding environment variables.
### Updating ###

### SSL Encryption ###
SSL Encryption is an optional but recommended feature. Automatic SSL is provided by Let's Encrypt. When using the webroot feature in certbot (refer to docker-compose.yml), you should mount the .well-known directory created to `/var/www/html/.well-known` within the panel container.

### Contributing ###
All issues regarding Pterodactyl Panel/Node are to be reported to https://github.com/Pterodactyl/Panel/issues.

##### Notes #####