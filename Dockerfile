FROM dreamacro/clash-premium:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tun

WORKDIR /root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    ipset \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/clash"]
CMD ["entrypoint.sh"]
