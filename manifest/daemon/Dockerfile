FROM node:8-alpine

MAINTAINER Cameron Carney <ccarney16@live.com>

ENV DAEMON_VERSION=v0.5.5

WORKDIR /srv/daemon

# Sadly everything has to be in one line to ensure that the image stays small...
##
# Put it as this:
# update alpine repos and install the required building tools
# Download Daemon
# Install the Daemon's dependencies
# Delete the build tools (gcc, python, etc)
# Purge Cache
##
RUN \
 apk --update --no-cache add coreutils curl openssl make gcc g++ python gnupg tar \
 && curl -Lo daemon.tar.gz https://github.com/Pterodactyl/Daemon/archive/${DAEMON_VERSION}.tar.gz \
 && tar --strip-components=1 -xzvf daemon.tar.gz \
 && rm -f daemon.tar.gz \
 && npm install --production \
 && apk del curl make gcc g++ python gnupg \
 && rm -rf /root/.npm /root/.node-gyp /root/.gnupg \
 /var/cache/apk/* /tmp/*

EXPOSE 8080

CMD [ "npm", "start" ]
