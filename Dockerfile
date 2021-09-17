# build clash
FROM golang:alpine as builder
RUN apk add --no-cache make git && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
    git clone https://github.com/Dreamacro/clash.git /clash-src \
    && mkdir -p /root/clash
    

WORKDIR /clash-src
RUN git checkout v1.7.0 && \
    go mod download

COPY Makefile /clash-src/Makefile
RUN make current

FROM --platform=${TARGETPLATFORM} alpine:latest
ENV TZ=Asia/Shanghai
ENV LOCAL_IP 192.168.0.0/16
ENV SS_ON 0

# build v2ray

WORKDIR /root
ARG TARGETPLATFORM
ARG TAG
COPY v2ray.sh /root/v2ray.sh

RUN set -ex \
	&& apk add --no-cache tzdata openssl ca-certificates \
	&& mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
	&& chmod +x /root/v2ray.sh \
	&& /root/v2ray.sh "${TARGETPLATFORM}" "${TAG}"

COPY --from=builder /clash-src/bin/clash /usr/local/bin/
COPY --from=builder /Country.mmdb /root/.config/clash/

COPY entrypoint.sh /root/clash/

RUN apk add --no-cache \
    ca-certificates  \
    bash  \
    curl \
    iptables  \
    ipset \
    bash-doc  \
    bash-completion  \
    rm -rf /var/cache/apk/* && \
    chmod a+x /root/clash/entrypoint.sh && \
    wget -O dashboard.zip https://github.com/haishanh/yacd/archive/gh-pages.zip && \
    unzip dashboard.zip -d /root/.config/clash && \
    mv /root/.config/clash/yacd-gh-pages /root/.config/clash/ui && \
    rm -rf dashboard.zip

VOLUME /etc/v2ray

ENTRYPOINT ["/root/clash/entrypoint.sh"]
CMD ["/usr/local/bin/clash"]
#CMD [ "/usr/bin/v2ray", "-config", "/etc/v2ray/config.json" ]
