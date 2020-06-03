FROM alpine:latest

LABEL maintainer="Cameron Carney <ccarney16@live.com>"

RUN \
  apk add --no-cache ca-certificates; \
  wget -O /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/v1.0.0-beta.5/wings_linux_amd64; \
  chmod +x /usr/local/bin/wings

EXPOSE 8080
EXPOSE 2022

CMD [ "/usr/local/bin/wings", "--config", "/var/lib/pterodactyl/config.yml" ]