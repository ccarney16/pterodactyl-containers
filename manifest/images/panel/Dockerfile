FROM alpine:3.16 as base

LABEL MAINTAINER="Cameron Carney <ccarney16@live.com>"

RUN \
    apk --update add curl gettext mariadb-client nginx php8 php8 php8-bcmath php8-common php8-dom php8-fileinfo \
    php8-fpm php8-gd php8-mbstring php8-openssl php8-pdo php8-phar php8-json php8-sodium \
    php8-pdo_mysql php8-posix php8-session php8-simplexml php8-tokenizer php8-ctype php8-zlib php8-zip php8-xmlwriter \
    tini \
    && mkdir -p /var/www/html /run/nginx /etc/nginx/conf.d/

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
    git clone https://github.com/pterodactyl/panel ./ --depth 1 --branch ${GIT_BRANCH} \
    && rm .git -rf \
    && chmod -R 755 storage/* bootstrap/cache \
    && find storage -type d > .storage.tmpl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && cp .env.example .env \
    && composer install --ansi --no-dev --optimize-autoloader \
    && chown -R nginx:nginx *;

RUN \
    yarn install --production \
    && yarn add cross-env \
    && yarn run build:production \
    && rm -rf node_modules

# Remove persistent data folders as they will be symlinked further down
RUN rm .env ./storage -rf

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
    ln -s /data/pterodactyl.conf .env;

EXPOSE 80 443
VOLUME [ "/data" ]

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
CMD [ "p:start" ]
