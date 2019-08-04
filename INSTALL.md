## Quick Start

<p><b>WARNING!</b> Before you start, it is recommended that you have a good understanding of Pterodactyl and Docker. This Quick start will be going through with using docker-compose.</p>

First make sure that your docker build is up to date (At the time, this works on Docker CE 17.x).


Clone/Download the repository to your local storage.


Rename the provided `.env.example` as `.env`


Edit variables to fit your need, such as database password and URL.


Run `docker-compose pull` to pull down the images. After `docker-compose up -d mysql` to start up mysql (Be sure to wait roughly 10-30 seconds to ensure that the database starts up).


When the base is set up, then run `docker-compose up -d panel`. This may take anywhere from 30 seconds to a few minutes when the panel starts up.


To create a user account, run `docker-compose run --rm panel php artisan p:user:make`


Now login to the panel using the given URL provided in .env and set up the daemon.


Copy the configuration to `/srv/daemon/config/core.json`. It is recommended to change the network parameters or the daemon may crash (If you have not used pterodactyl before, it will attempt to use the 172.18.0.0/16 block). In json notation, you should modify `docker.network.interfaces.v4.subnet` and `docker.network.interfaces.v4.gateway`.


Run `docker-compose up -d daemon` to complete setting up.


If you have any problems, refer to `docker-compose logs` to identify any issues.
You should be all set and rocking!

## Updating

Refer to https://docs.pterodactyl.io/ when updating to a newer version. `php artisan pterodactyl:env` and `php artisan pterodatyl:mail` are not required if you have the variables set outside of `/data/pterodactyl.conf`.

## Migrating

For users who are moving to a containerized platform, the `.env` file within the original panel installation should be copied to the data folder [`/data`] as `pterodactyl.conf`.

<p>Tweaking the config file (both .env and pterodactyl.conf) might be required</p>

## SSL Encryption

Set `SSL` to true in `.env` and provide SSL certificates. Let's Encrypt is also supported, just add in certbot from `docker-compose.extra.yml` and volumes to panel.

## Workers/cron in seperate container

While this container is able to run both the cron daemon and pterodactyl workers required for the panel to function correctly, they can be disabled in favor of running them in another container. Just set `DISABLE_WORKERS` to true and use the provided examples for seperate workers in `docker-compose.extra.yml`.

## Enabling Mobile App
Set `MOBILE_APP` to true in `.env`
