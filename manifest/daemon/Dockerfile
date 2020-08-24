FROM alpine:latest

ARG VERSION

LABEL maintainer="Cameron Carney <ccarney16@live.com>"

ENV DAEMON_VERSION=${VERSION}


RUN \
  apk add --no-cache ca-certificates; \
  wget -O /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/${DAEMON_VERSION}/wings_linux_amd64; \
  chmod +x /usr/local/bin/wings

EXPOSE 8080
EXPOSE 2022

# Default Work Directory
WORKDIR /var/lib/pterodactyl

CMD [ "/usr/local/bin/wings", "--config", "./config.yml" ]
