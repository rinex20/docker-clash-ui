#FROM rinex20/docker-clash-ui:latest
FROM dreamacro/clash:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh /usr/local/bin/

RUN apk add --no-cache \
    ipset  \
    iproute2 \
    rm -rf /var/cache/apk/* && \
    chmod a+x /usr/local/bin/entrypoint.sh


ENTRYPOINT ["entrypoint.sh"]

CMD ["/clash"]

