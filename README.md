

# Pterodactyl Panel Dockerfile

[![Docker Repository on Quay](https://quay.io/repository/ccarney/pterodactyl-panel/status "Docker Repository on Quay")](https://quay.io/repository/ccarney/pterodactyl-panel)

Pterodactyl, a free an open source agnostic game panel... In a Container!

## Quick Start

Copy and modify the contents of *.env.example* to *.env* and run the setup under the commands provided:

*Docker*:

You can run the panel using this command: 
`docker run --name=pterodactyl-panel -p 80:80 -p 443:443 -v data:/data --env-file=./.env quay.io/ccarney/pterodactyl-panel:{version}`

><small>This command alone does not provide the full environment for the panel. This is more or less a reference. If you wish to have a full environment, it is recommended to use the method below.</small>

__or__ *Docker Compose*:

A *docker-compose.yml* file is provided for anyone who uses docker compose.
You can start the panel by running `docker-compose up -d`.

## The _/data_ Volume

The data volume for the image is used to maintain persistence:

* *pterodactyl.conf*: The .env file for laravel, automatically generated if missing on server startup. This file is only used if a variable is not provided by the container.
* *storage/*: Laravel storage, contains cache, logs, and files that need to be writable to the panel.
* *cache/*: configuration cache for the panel.

><small>It is recommend to create a directory mount for this, but isnt required.</small>

## Updating

Refer to https://docs.pterodactyl.io/ when updating to a newer version. `php artisan pterodactyl:env` and `php artisan pterodatyl:mail` are not required if you have the variables set outside of */data/pterodactyl.conf*.

## Migrating

Refer to [https://docs.pterodactyl.io/](https://docs.pterodactyl.io/) for migrating. For users who are coming from a non dockerized setup, you can put your panel .env within the */data* volume and rename it as pterodactyl.conf. Once all set, start up the container environment.

## SSL Encryption

SSL Encryption is an optional but recommended feature. Automatic SSL within *docker-compose.yml* is provided by Let's Encrypt. Refer to *docker-compose.yml* for more information.

## Contributing

All issues regarding Pterodactyl Panel/Node are to be reported to https://github.com/Pterodactyl/Panel/issues.

## Useful Links

*Pterodactyl Project*:

[https://pterodactyl.io/](https://pterodactyl.io/)

[https://docs.pterodactyl.io/](https://docs.pterodactyl.io/)

[https://github.com/Pterodactyl/](https://github.com/Pterodactyl/)

*Docker*:

[https://docs.docker.com/](https://hub.docker.com/)

[https://hub.docker.com/](https://hub.docker.com/)
