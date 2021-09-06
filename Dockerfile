FROM rinex20/docker-clash-ui:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh ./

RUN apk add --no-cache \
    ipset && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /root/clash && \
    chmod a+x ./entrypoint.sh && \
    chmod a+x /root/clash/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["clash"]
