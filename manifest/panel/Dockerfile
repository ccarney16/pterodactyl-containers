FROM alpine:edge as base

ARG VERSION
ARG ENABLE_MOBILE=false

LABEL MAINTAINER="Cameron Carney <ccarney16@live.com>"

ENV STARTUP_TIMEOUT=5 \
    PANEL_VERSION=${VERSION}

WORKDIR /var/www/html
VOLUME [ "/data" ]

RUN \
    apk --update add curl gettext nginx php7 php7 php7-bcmath php7-common php7-dom php7-fileinfo \
    php7-fpm php7-gd php7-memcached php7-mbstring php7-openssl php7-pdo php7-phar php7-json \
    php7-pdo_mysql php7-session php7-simplexml php7-tokenizer php7-ctype php7-zlib php7-zip tini \
    && mkdir -p /var/www/html /run/nginx

COPY ./ /

# Expose HTTP and HTTPS ports
EXPOSE 80 443

ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]

CMD [ "p:start" ]

# Build phase of the container
# This is where composer is added and pterodactyl properly setup
FROM base as devel

RUN \
    apk add yarn

RUN \
    curl -Lo panel.tar.gz https://github.com/Pterodactyl/Panel/archive/${PANEL_VERSION}.tar.gz \
    && tar --strip-components=1 -xzvf panel.tar.gz \
    && rm panel.tar.gz \
    && chmod -R 755 storage/* bootstrap/cache \
    && find storage -type d > .storage.tmpl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && cp .env.example .env \
    && composer install --ansi --no-dev --optimize-autoloader \
    && rm .env ./storage -rf \
    && chown nginx:nginx * -R

RUN \
    yarn install --production; \
    yarn add cross-env; \
    yarn run build:production; \
    rm -rf node_modules;


# Final Production phase of the controller
# All build requirements get scrapped as to maintain a small image
FROM base as final

COPY --from=devel --chown=nginx:nginx /var/www /var/www
