FROM golang:1.21-alpine as build

ARG VERSION
ENV VERSION=${VERSION}
ARG GIT_BRANCH=release/${VERSION}

RUN \
  apk add git; \
  cd /; \
  git clone https://github.com/pterodactyl/wings --depth 1 --branch ${GIT_BRANCH}; \
  cd wings; \
  go build -ldflags="-s -w";

FROM alpine:latest as final

LABEL maintainer="Cameron Carney <ccarney16@live.com>"

ARG VERSION
ENV VERSION=${VERSION}

RUN \
  apk add --no-cache ca-certificates tini tzdata; \
  mkdir -p /etc/pterodactyl /var/log/pterodactyl /tmp/pterodactyl 

# Copy wings from build stage
COPY --from=build /wings/wings /usr/local/bin
COPY ./root /

EXPOSE 8080
EXPOSE 2022

# Default Work Directory
WORKDIR /var/lib/pterodactyl

ENTRYPOINT [ "tini", "--", "/entrypoint.sh" ]
