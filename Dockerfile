FROM rinex20/docker-clash-ui:base
FROM dreamacro/clash-premium:latest as base

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh run.sh ./

COPY --from=base /clash /usr/local/bin/clash-premium

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

# clash
# CMD ["clash"]
# clash premium
CMD ["clash-premium"]

