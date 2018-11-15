FROM alpine:latest

ENV VERSION=v1.0.1 \
    UID=500

RUN mkdir /srv/daemon -p; \
    wget -P /srv/daemon https://github.com/pterodactyl/sftp-server/releases/download/${VERSION}/sftp-server; \
    chmod +x /srv/daemon/sftp-server; \
    addgroup -S -g ${UID} pterodactyl && adduser -S -D -H -G pterodactyl -u ${UID} -s /bin/false pterodactyl

EXPOSE 2022

WORKDIR /srv/daemon
ENTRYPOINT [ "./sftp-server" ]
CMD [ "-port", "2022" ] 