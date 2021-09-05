FROM rinex20/docker-clash-ui:latest

WORKDIR /root
COPY entrypoint.sh ./

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["clash"]
