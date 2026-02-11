FROM alpine:latest

RUN apk add --no-cache dante-server

COPY sockd.conf.template /etc/sockd.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1080

ENTRYPOINT ["/entrypoint.sh"]