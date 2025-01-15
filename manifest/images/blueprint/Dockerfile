FROM --platform=$TARGETOS/$TARGETARCH docker.io/ccarney16/pterodactyl-panel:v1.11.10 AS base

# Required for tput (used in blueprint.sh)
ENV TERM=xterm
ENV NODE_OPTIONS=--openssl-legacy-provider

RUN \
    microdnf module enable -y nodejs:20 && \
    microdnf install -y findutils git nodejs rsync unzip yarnpkg zip

# Download and unzip the latest Blueprint release
RUN \
    yarn install --production && \
    yarn add cross-env && \
    mkdir -p /data/storage && \
    cp .env.example /data/storage/pterodactyl.conf && \
    curl -Lo blueprint.zip $(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4) && \
    unzip -o blueprint.zip -d /var/www/html && \
    echo "WEBUSER=caddy" >> .blueprintrc && \
    echo "OWNERSHIP=caddy:caddy" >> .blueprintrc && \
    echo "FOLDER=$(pwd)" >> .blueprintrc && \
    bash blueprint.sh && \
    chown -R caddy:caddy * && \
    find storage/ -mindepth 1 -type d >> .storage.tmpl && \
    rm -rf blueprint.zip /data/storage

# Copy contents to root directory
COPY ./root/ /

# # Set CMD to run the listen script in the background and start supervisord
# CMD /listen.sh & exec supervisord -n -c /etc/supervisord.conf