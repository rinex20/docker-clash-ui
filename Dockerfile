FROM rinex20/docker-clash-ui:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint-private.sh ./

RUN apk add --no-cache \
    ipset  \
    rm -rf /var/cache/apk/* && \
    chmod a+x ./entrypoint-private.sh

ENTRYPOINT ["./entrypoint-private.sh"]
CMD ["clash"]
