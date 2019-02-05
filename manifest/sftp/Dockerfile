FROM alpine:latest

ARG VERSION

ENV SFTP_VERSION=${VERSION} \
    UID=500

RUN mkdir /srv/daemon -p; \
    wget -P /srv/daemon https://github.com/pterodactyl/sftp-server/releases/download/${SFTP_VERSION}/sftp-server; \
    chmod +x /srv/daemon/sftp-server; \
    addgroup -S -g ${UID} pterodactyl && adduser -S -D -H -G pterodactyl -u ${UID} -s /bin/false pterodactyl

EXPOSE 2022

WORKDIR /srv/daemon
ENTRYPOINT [ "./sftp-server" ]
CMD [ "-port", "2022" ] 