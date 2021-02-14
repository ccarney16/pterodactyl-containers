FROM alpine:edge as base

LABEL MAINTAINER="Cameron Carney <ccarney16@live.com>"

RUN \
    apk --update add curl gettext nginx openssl php7 php7 php7-bcmath php7-common php7-dom \
    php7-fileinfo php7-fpm php7-gd php7-memcached php7-mbstring php7-openssl php7-pdo php7-phar \
    php7-json php7-pdo_mysql php7-session php7-simplexml php7-tokenizer php7-ctype php7-zlib \
    php7-zip tini \
    && mkdir -p /var/www/html /run/nginx

# Build phase of the container
# This is where composer is added and pterodactyl properly setup
FROM base as build

ARG VERSION
ARG GIT_BRANCH=release/${VERSION}

ENV VERSION=${VERSION}

WORKDIR /var/www/html

RUN \
    apk add yarn git;

RUN \
    git clone https://github.com/pterodactyl/panel ./ --depth 1 --branch ${GIT_BRANCH}; \
    rm .git -rf; \
    chmod -R 755 storage/* bootstrap/cache; \
    find storage -type d > .storage.tmpl; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    cp .env.example .env; \
    composer install --ansi --no-dev --optimize-autoloader; \
    chown -R nginx:nginx *;

RUN \
    yarn install --production; \
    yarn add cross-env; \
    yarn run build:production; \
    rm -rf node_modules;

# Remove persistent data folders as they will be symlinked further down
RUN rm .env ./storage ./bootstrap/cache -rf

# Final Production phase of the controller
# All build requirements get scrapped as to maintain a small image
FROM base as production

ARG VERSION

ENV VERSION=${VERSION}

WORKDIR /var/www/html

COPY --from=build --chown=nginx:nginx /var/www /var/www
COPY ./root/ /

# Symlink storage, config and cache to /data
RUN \
    ln -s /data/storage storage; \
    ln -s /data/cache bootstrap/cache; \
    ln -s /data/pterodactyl.conf .env;

EXPOSE 80 443
VOLUME [ "/data" ]

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
CMD [ "p:start" ]