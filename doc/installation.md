# Installation

> **WARNING!** Before you start, it is recommended to have a good understanding of Pterodactyl and Docker. This documentation is geared towards experienced users.

### Requirements

- Latest version of Docker
- docker-compose

### Downloading Project

While git is not a requirement to running this software, it is recommended if you want to keep up to date with the latest repository files.

### Deployment Profiles & Configs

This project contains various configurations to meet certain use cases. The following configurations are explained below:

> **Config Options**
> - **default** - Default service, contains everything except for build parameters. Designed as a turnkey solution.
> - **devel** - Same as **default**, except has build options and parameters to build containers.
> - **minimal** - Minimal configuration, contains the absolute bare essentials to operate, useful for behind web proxies or if needing to override settings.

Profiles are used to enable or disable services when executing docker-compose. Currently the project utilizes two profiles to separate services into the following categories:

> **Profile Options**
> - **panel** - Toggles services related to the panel. This includes workers, cron and databases.
> - **daemon** - This toggles the daemon service. Not including this will disable the daemon from being started up.

### Configuring Services

### Starting Services
