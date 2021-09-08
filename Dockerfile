









# build clash
FROM golang:alpine as builder
RUN apk add --no-cache make git && \
    wget -O /Country.mmdb https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb && \
    git clone https://github.com/Dreamacro/clash.git /clash-src \
    && mkdir -p /root/clash
    

WORKDIR /clash-src
RUN git checkout v1.6.5 && \
    go mod download

COPY Makefile /clash-src/Makefile
RUN make current

FROM alpine:latest
ENV TZ=Asia/Shanghai
ENV LOCAL_IP 192.168.0.0/16
ENV SS_ON 0

# build shadowsocks-libev
WORKDIR /root
COPY v2ray-plugin.sh /root/v2ray-plugin.sh
COPY xray-plugin.sh /root/xray-plugin.sh
RUN set -ex \
	&& runDeps="git build-base c-ares-dev autoconf automake libev-dev libtool libsodium-dev linux-headers mbedtls-dev pcre-dev" \
	&& apk add --no-cache --virtual .build-deps ${runDeps} \
	&& mkdir -p /root/libev \
	&& cd /root/libev \
	&& git clone --depth=1 https://github.com/shadowsocks/shadowsocks-libev.git . \
	&& git submodule update --init --recursive \
	&& ./autogen.sh \
	&& ./configure --prefix=/usr --disable-documentation \
	&& make install \
	&& apk add --no-cache \
		tzdata \
		rng-tools \
		ca-certificates \
		$(scanelf --needed --nobanner /usr/bin/ss-* \
		| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
		| xargs -r apk info --installed \
		| sort -u) \
	&& apk del .build-deps \
	&& cd /root \
	&& rm -rf /root/libev \
	&& chmod +x /root/v2ray-plugin.sh /root/xray-plugin.sh \
	&& /root/v2ray-plugin.sh \
	&& /root/xray-plugin.sh \
	&& rm -f /root/v2ray-plugin.sh /root/xray-plugin.sh

# end of build ss

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

VOLUME /etc/shadowsocks-libev

ENTRYPOINT ["/root/clash/entrypoint.sh"]
CMD ["/usr/local/bin/clash"]
