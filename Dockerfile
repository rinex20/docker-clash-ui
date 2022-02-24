
FROM dreamacro/clash-premium:latest

ENV TZ=Asia/Shanghai

WORKDIR /root

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
    chmod a+x ./run.sh ./entrypoint.sh && \
    wget -O dashboard.zip https://github.com/haishanh/yacd/archive/gh-pages.zip && \
    unzip dashboard.zip -d /root/.config/clash && \
    mv /root/.config/clash/yacd-gh-pages /root/.config/clash/ui && \
    rm -rf dashboard.zip

CMD ["/clash"]
