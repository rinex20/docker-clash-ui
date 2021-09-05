FROM rinex20/docker-clash-ui:latest

WORKDIR /root
COPY entrypoint-private.sh ./

RUN apk add --no-cache \
    ipset  \
    rm -rf /var/cache/apk/* && \
    chmod a+x ./entrypoint-private.sh

ENTRYPOINT ["./entrypoint-private.sh"]
CMD ["clash"]
