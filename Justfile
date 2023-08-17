

######################
## PROJECT COMMANDS ##
######################

# This section is dedicated towards project specific commands
# that may be used by the end user.

# Determine the path of docker and docker-compose, or docker compose
docker-bin      := `which docker`
compose-bin     := `which docker-compose 2>/dev/null || echo $(which docker) compose`

# Execute Artisan commands
artisan *args:
    {{compose-bin}} run --rm --no-deps panel php artisan "$@"

dump-dir                := invocation_directory()
dump-mariadb-opt-flags  := "--single-transaction"

# Dumps the application to current or specified directory
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
