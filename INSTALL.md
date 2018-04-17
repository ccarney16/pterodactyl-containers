## Quick Start

<p><b>WARNING!</b> Before you start, it is recommended that you have a good understanding of Pterodactyl and Docker. This Quick start will be going through with using docker-compose.</p>

First make sure that your docker build is up to date (At the time, this works on Docker CE 17.x).


Clone/Download the repository to your local storage.


Rename the provided `.env.example` as `.env`

<!-- Clone/download the repo, then copy the .env.example as .env within the same directory.
The .env file contains all the variables to the containers functions including the panel.

<p>If you are migrating from a panel that was not in a container, go down to <i>Migrating</i> for more information.</p>

Once that process is done, run `docker-compose pull` to pull the required container images down.


In order for the panel to set up the database, mysql needs to be started first: `docker-compose up -d mysql`.


After 5-10 seconds, issue this to start the panel: `docker-compose up -d panel`. The panel should be up and running, verify that it is accepting connections.


You will need a username and password to login: `docker-compose run --rm panel php artisan p:user:make`


`docker-compose run --rm daemon <token>`

`docker-compose up -d` -->

## Updating

Refer to https://docs.pterodactyl.io/ when updating to a newer version. `php artisan pterodactyl:env` and `php artisan pterodatyl:mail` are not required if you have the variables set outside of `/data/pterodactyl.conf`.

## Migrating

For users who are moving to a containerized platform, the `.env` file within the original panel installation should be copied to the data folder [`/data`] as `pterodactyl.conf`.

<p>Tweaking the config file (both .env and pterodactyl.conf) might be required</p>

## SSL Encryption

Set `SSL` to true in `.env` and provide SSL certificates. Let's Encrypt is also supported, just add in certbot from `docker-compose.extra.yml` and volumes to panel.

## Workers/cron in seperate container

While this container is able to run both the cron daemon and pterodactyl workers required for the panel to function correctly, they can be disabled in favor of running them in another container. Just set `DISABLE_WORKERS` to true and use the provided example in `docker-compose.extra.yml`.