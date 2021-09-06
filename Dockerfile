FROM rinex20/docker-clash-ui:base as base
FROM dreamacro/clash-premium:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh run.sh ./

COPY --from=base /root/.config/clash/ui /ui

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    ipset \
    iproute2 \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x ./run.sh ./entrypoint.sh


ENTRYPOINT ["./run.sh"]

CMD ["/clash"]

