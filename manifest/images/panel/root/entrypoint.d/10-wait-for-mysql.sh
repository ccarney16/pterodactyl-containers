#!/bin/bash

# Check if MySQL is up and running
echo "[wait-for-mysql] Waiting for database connection..."
i=0
until wait-for -q -t 15 $DB_HOST:$DB_PORT; do
    echo "[wait-for-mysql] Database connection timeout"

    # wait for 5 seconds before check again
    sleep 5
    i=`expr $i + 1`
    if [ "$i" = "5" ]; then
        echo "[wait-for-mysql] Connection threshold reached, unable to contact MySQL (Is MySQL Running?)"

        # Send kill signal to tini
        kill 1
    fi
done
