# Pterodactyl Panel Dockerfile #
**A Free and Open Source Agnostic Game Panel**

**Welcome to the Testing Branch, this branch is highly unstable and will change often.**

----

### Usage ###

*Docker*:

You can run the panel using this command: `docker run --name=pterodactyl-panel -p 80:80 -p 443:443 --env-file=./.env quay.io/ccarney/pterodactyl-panel:testing`. 

It is recommended to create a .env file for variables.

__or__

*Docker Compose*:

A _docker-compose.yml_ file is provided for anyone who uses docker compose.
You can start the panel by running `docker-compose up -d`; You can edit variables using the environment section within _docker-compose.yml_.

### The _/data_ Volume ###

The data volume for the image is used to maintain persistence:

* *pterodactyl.conf*: The .env file for laravel, automatically generated if missing on startup. It is recommended not to modify this and instead use environmental variables instead.
* *storage/*: Laravel storage, contains cache, logs, and files that need to be writable to the panel.
* *cache/*: configuration cache for the panel.

It is recommend to create a directory mount for this, but isnt required.

### Updating ###

Refer to https://docs.pterodactyl.io/ when updating to a newer version. `php artisan pterodactyl:env` and `php artisan pterodatyl:mail` are not required if you have the variables set outside of */data/pterodactyl.conf*.

### Migrating ###

Refer to https://docs.pterodactyl.io/ for migrating. For users who are coming from a non dockerized setup, you can put it within the */data* volume and rename it as pterodactyl.conf. Once all set, start up the container environment.

### Entrypoint Commands ###

* p:start - Starts the panel web server and requirements (We don't provide cache and database!).

### SSL Encryption ###

SSL Encryption is an optional but recommended feature. Automatic SSL within *docker-compose.yml* is provided by Let's Encrypt. When using the webroot feature in certbot (refer to docker-compose.yml), you should mount the .well-known directory created to `/var/www/html/public/.well-known` within the panel container.

### Contributing ###

All issues regarding Pterodactyl Panel/Node are to be reported to https://github.com/Pterodactyl/Panel/issues.

### Useful Links ###

*Pterodactyl Project*:

https://pterodactyl.io/

https://docs.pterodactyl.io/

https://github.com/Pterodactyl/

*Docker*:

https://docs.docker.com/

https://hub.docker.com/
