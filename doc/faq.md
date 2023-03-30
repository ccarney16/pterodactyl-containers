# FAQ

### Can you add _X_ extension?

The goal of this project is to keep inline with pterodactyl while providing an easy to use deployment setup. Third Party extensions will not be added in this image. You can add extensions during the building phase of the panel image.

### Does this project support other platforms?

Docker and Docker Compose are the primary ways of setting up the panel. There is currently no plans to build templates or configuration files for other platforms. Any templates or configurations posted outside of this repository is not made by me.

### Does this work with a reverse proxy?

Reverse Proxies such as NGINX and Traefik are supported. It is recommended to use the `TRUSTED_PROXIES` variable.