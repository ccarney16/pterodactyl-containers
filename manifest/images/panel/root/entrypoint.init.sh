#!/bin/bash

# if container is starting the web server, and is root,
# change permission of /data to caddy user.
if [ "${1}" == "start-web" ] && [ "$user_id" = "0" ]; then
    chown -R caddy:caddy /data
fi
