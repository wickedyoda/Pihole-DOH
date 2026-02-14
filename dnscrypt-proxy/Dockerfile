FROM alpine:3.21

RUN apk add --no-cache dnscrypt-proxy gettext

COPY entrypoint.sh /entrypoint.sh
COPY dnscrypt-proxy.toml.tpl /templates/dnscrypt-proxy.toml.tpl

RUN chmod +x /entrypoint.sh && mkdir -p /config

EXPOSE 5053/tcp 5053/udp

ENTRYPOINT ["/entrypoint.sh"]
