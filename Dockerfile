FROM alpine:edge

MAINTAINER Cameron Carney <ccarney16@live.com>

ENV CONFIG_FILE=/data/pterodactyl.conf \
    STARTUP_TIMEOUT=15 \
    STORAGE_DIR=/data/storage \
    PANEL_VERSION=v0.6.0

WORKDIR /var/www/html

RUN \
 echo http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
 && echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
 && echo http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
 && apk update \
 && apk add curl gettext nginx php7 php7 php7-bcmath php7-common php7-dom php7-fpm php7-gd \
 php7-memcached php7-mbstring php7-openssl php7-pdo php7-phar php7-json php7-pdo_mysql \ 
 php7-session php7-tokenizer php7-ctype php7-zlib php7-zip supervisor \
 && mkdir -p /var/www/html /run/nginx

RUN curl -Lo "${PANEL_VERSION}.tar.gz" https://github.com/Pterodactyl/Panel/archive/${PANEL_VERSION}.tar.gz \
 && tar --strip-components=1 -xzvf ${PANEL_VERSION}.tar.gz \
 && rm "${PANEL_VERSION}.tar.gz" \
 && chmod -R 755 storage/* bootstrap/cache \
 && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer install --ansi --no-dev \
 && mv ./storage storage.template \
 && chown nginx:nginx * -R

COPY ./manifest /

VOLUME [ "/data" ]

# Expose HTTP and HTTPS ports
EXPOSE 80 443

ENTRYPOINT [ "/bin/ash", "/entrypoint.sh" ]

CMD [ "p:start" ]
