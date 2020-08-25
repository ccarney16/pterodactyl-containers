FROM golang:1.14-alpine as build

ARG VERSION

RUN \
  apk add git; \
  cd /; \
  git clone https://github.com/pterodactyl/wings -b ${VERSION}; \
  cd wings; \
  go build -ldflags="-s -w";

FROM alpine:latest as final

LABEL maintainer="Cameron Carney <ccarney16@live.com>"

ARG VERSION

ENV DAEMON_VERSION=$VERSION

RUN \
  apk add --no-cache ca-certificates; \
  mkdir -p /etc/pterodactyl /var/log/pterodactyl /tmp/pterodactyl 

# Copy wings from build stage
COPY --from=build /wings/wings /usr/local/bin

EXPOSE 8080
EXPOSE 2022

# Default Work Directory
WORKDIR /var/lib/pterodactyl

CMD [ "/usr/local/bin/wings" ]
