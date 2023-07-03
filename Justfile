#!/usr/bin/env -S just --justfile
###
#
# -- ZYPHICO PROJECT DEPLOYMENT --
#
# 	This makefile serves as the core for many of the 
# projects zyphico uses to deploy docker-compose projects.
#  
###

## JUSTFILE SETTINGS ##

set ignore-comments         := true
set positional-arguments    := true

## ENVIRONMENT VARIABLES ##

_project-dir    := justfile_directory()
_build-dir      := _project-dir + "/manifest/images"
_deploy-dir	    := _project-dir + "/manifest/deploy"
_base-dir       := _deploy-dir + "/base"
_templates-dir  := _deploy-dir + "/templates"

# Determine the path of docker and docker-compose, or docker compose
docker-bin      := `which docker`
compose-bin     := `which docker-compose 2>/dev/null || echo $(which docker) compose`

force           := "false"
template        := "default" 
override        := "template"

build-env       := "--env-file ./manifest/images/build.env --file ./manifest/images/build.yml"

dump-dir          := justfile_directory() + "/data/dump"
dump-mariadb-opt-flags  := "--single-transaction"

## CORE COMMANDS ##
    
# Commands that represent the backbone of the deployment file.
# These commands build and maintain the project.

# Returns the status of the compose project
status:
    #!/bin/bash
    printf "\n## Project Status ##\n\n"
    printf "  Deployed: yes \n"
    printf "  All Profiles: \n"
    {{compose-bin}} config --profiles | sed 's/[^[:blank:]]/    - &/'
    printf "  Active Profiles: \n"
    printf "  Active Services: \n"
    {{compose-bin}} config --services | sed 's/[^[:blank:]]/    - &/'
    printf "\n\n" 
    printf "Containers:\n"

build *args:
	{{compose-bin}} {{build-env}} build "$@"

# Assigns a new tag for a given service
build-tag service new-tag:
    @{{docker-bin}} tag $({{compose-bin}} {{build-env}} config --format json | jq -r '.services.{{service}}.image') {{new-tag}}

# Run Docker Compose commands
compose *args:
    {{compose-bin}} "$@"

# Deploy the project
deploy:
    #!/bin/bash
    set -euf -o pipefail

    if ! [ "{{force}}" == "true" ]; then
        if [ -f docker-compose.yml ]; then
            printf "Warning! This project is already deployed! Redeploying will override certain configuration files.\n"
            read -p "Please make sure you have a proper backup of this project. Do you wish to continue (y/N)? " yn
            if ! [[ ${yn,,} == y* ]]; then
                exit 1
            fi
        fi
    fi

    # Check if the template exists first
    ls {{_templates-dir}}/{{template}}/docker-compose.yml

    # Copy configuration 
    printf "Copying base configuration.\n"
    cp -rnvT manifest/deploy/base .

    printf "Applying template environment.\n"
    cp -rfvT {{_templates-dir}}/{{template}} .

    echo "done"

# Add or modify shell-formatted environment files
set-environment file env:
    #!/bin/bash
    set -e

    if [ -f {{file}} ]; then
        read -d "=" -rasplit<<< "{{env}}"
        if grep -q "^${split[0]}=" {{file}}; then
            sed -i "s|${split[0]}=.*|{{env}}|" {{file}}
        else
            echo "{{env}}" >> {{file}}
        fi
    else
        printf "Missing file '{{file}}'...\n"
        exit 1
    fi

# Clears the environment variable from the selected file
unset-environment file env:
    #!/bin/bash
    set -e
    if [ -f {{file}} ]; then
        sed -i "/{{env}}=.*/d" {{file}}
    else
        printf "Missing file '{{file}}'...\n"
        exit 1
    fi    

set-compose-environment env: (set-environment ".env" env)
set-container-environment container env: (set-environment "conf.d/" + container + ".env" env)
set-profiles profile: (set-environment ".env" "COMPOSE_PROFILES=" + profile)

# Force reset the project
reset:
	#!/bin/bash
	if [ "{{force}}" == "true" ]; then
		git clean -x -d -f
		git reset --hard
	else
		printf "!!ERROR!!\n\n"
		printf "This command can only be issued with FORCE set to true!\n"
		printf "If you wish to wipe this project, please perform a backup and run:\n\n"
		printf "  just force=true reset\n\n"
	fi

## PROJECT COMMANDS ##

# This section is dedicated towards project specific commands
# that may be used by the end user.

#setup: install fix-permissions

# Execute Artisan commands
artisan *args:
    {{compose-bin}} run --rm --no-deps panel php artisan "$@"

# Dumps the application to a specified directory
dump dir=dump-dir:
    #!/bin/bash
    set -euf -o pipefail

    printf "## Starting Pterodactyl Database Dump ##\n"

    printf "Dumping Database to {{dir}}"
    {{compose-bin}} run \
        --rm -v "{{dir}}":/backup \
        --entrypoint /bin/sh \
        --user root \
        panel -c "
            export MYSQL_PWD=\"\${DB_PASSWORD}\"
            mysqldump --user=\${DB_USERNAME} --host=\${DB_HOST} --port=\${DB_PORT} {{dump-mariadb-opt-flags}} --databases \${DB_DATABASE} > /backup/db-dump.sql" 

    printf "## Application Dump Complete ##\n\n"

    printf "!! Warning, this application only has exported the database configuration for pterodactyl.\n"
    printf "Please make sure that the database and configuration of the panel and daemon are backed up separately.\n"
    sleep 0.5

# Import Database configuration
import dir=dump-dir:
    #!/bin/bash

# Corrects volume user permissions when using rootless containers or when containers dont set permissions themselves.
set-permissions:
    @printf "Updating Permissions\n"
    {{compose-bin}} run --rm --no-deps --user root --entrypoint sh panel -c "chown caddy:caddy /data"
    {{compose-bin}} run --rm --no-deps --user root --entrypoint sh mariadb -c "chown mysql:mysql /var/lib/mysql"
