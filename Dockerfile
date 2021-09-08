FROM rinex20/docker-clash-ui:latest

ENV LOCAL_IP 192.168.0.0/16
ENV MODE tproxy
ENV SS_ON 0

WORKDIR /root
COPY entrypoint.sh ./
COPY run.sh ./

RUN apk add --no-cache \
    ipset \
    rm -rf /var/cache/apk/* && \
    mkdir -p /root/clash && \
    chmod a+x ./run.sh ./entrypoint.sh && \
    wget -O dashboard.zip https://github.com/haishanh/yacd/archive/gh-pages.zip && \
    unzip dashboard.zip -d /root/.config/clash/dashboard

ENTRYPOINT ["./run.sh"]
CMD ["/usr/local/bin/clash"]
